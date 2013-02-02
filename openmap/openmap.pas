unit openmap;
// OpenStreetMap Utilities Unit
// License: New BSD License
// Documentation at: http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
// Revision History:
// @001 2009.11.19 Noah SILVA Started library
// @002 2009.11.20 Noah SILVA Added omGetTileFile
// @003 2010.01.03 Noah SILVA Added Tile Number -> Location functions

{$mode objfpc}{$H+}

interface

TYPE
 TOSMTile = Record
              Zoom : Integer;
              TileX: Integer;
              TileY: Integer;
            end;
// Gets the URL for a tile containing the specified Latitude, Longitude, and
// Zoom level.
Function omGetTileURL(const Lat:Real; const Lon:Real; const Zoom:Integer):String;
// Note that the tile contains the specified point, it is not centered on it.
// Zoom = 0..18.  (0 is the whole earth, 18 is the highest zoom)
Function omGetTileURL(const Tile:TOSMTile):String; overload;             //@002=

// Returns the URL to a static map (image) for the given location and zoom level
Function omGetStaticMapURL(const Lat:Real; const Lon:Real;
                           const Zoom:Integer):String;
// The image is composed of stitched-together tiles
// This service is not guaranteed by OpenStreetMap and may be unreliable.

// Fetches the map tile for a given location and zoom level, and returns a file
// name for the caller to retrieve it at.
Function omGetTileFile(const Lat:Real; const Lon:Real;                   //@002+
                       const Zoom:Integer):String;  Overload;            //@002+
Function omGetTileFile(Const Tile:TOSMTile):String; Overload;            //@002+

// Returns a structure with the tile's x, y, and zoom.  This is useful if you
// want to get a tile to the left, right, etc.
Function omGetTile(const Lat:Real; const Lon:Real;                       //@002+
                   const ZoomLevel:Integer):TOSMTile;                    //@002+

// Calculates the Longitude of the NW corner of a tile.
Function omTile2Long(Const Tile:TOSMTile):Real;                          //@003+
// Calculates the Latitude of the NW corner of a tile.
Function omTile2Lat(Const Tile:TOSMTile):Real;                           //@003+
Function MarkerX(Const Tile:TOSMTile;
                 Const Lat:Real; Const Long:Real):Integer;               //@003+
Function MarkerY(Const Tile:TOSMTile;
                 Const Lat:Real; Const Long:Real):Integer;               //@003+
implementation

uses
  Classes, SysUtils,
  math,     // for Ln, Cos, etc.
  MD5,      // for Hash
  httpsend; // for Internet

Var
 CacheRoot:String;  // Root for storing Map Images                       //@003+

//@002+ Begin of Insertion
// Private function, gets tile X from coordinates and zoom level
Function omGetTileX(const Lat:Real; const Lon:Real; const Zoom:Integer):integer;
  Begin
    Result := Floor((lon + 180) / 360 * Power(2, Zoom));
  end;

// Private function, gets tile Y from coordinates and zoom level
Function omGetTileY(const Lat:Real; const Lon:Real; const Zoom:Integer):integer;
  Const
    PI = 3.14159;
  Begin
    Result := Floor( (1 - ln(Tan(lat * PI / 180)
                        + 1 / Cos(lat * PI / 180))
                             / PI) / 2 * Power(2, Zoom));
  end;

//@002+ Begin of Insertion
Function omGetTile(const Lat:Real; const Lon:Real;
                   const ZoomLevel:Integer):TOSMTile;
  Begin
    With Result Do
      Begin
        Zoom := ZoomLevel;
        TileX := omGetTileX(lat, lon, ZoomLevel);
        TileY := omGetTileY(lat, lon, ZoomLevel);
      End;  // of WITH
  End; // of FUNCTION


Function omGetURLTileNumber(const Tile:TOSMTile):String;  overload;
// Returns tile number triplet in such a way as to be conducive to use for a
// HTTP URL for the OSM Tile Server
  Begin
    With Tile do
      result :=  IntToStr(Zoom) + '/' + FloatToStr(TileX) + '/' + FloatToStr(TileY);
  End;

Function omGetFileTileNumber(const Tile:TOSMTile):String;  overload;
// Returns tile number triplet in such a way as to be conducive to use for a
// HTTP URL for a file name
  Begin
    With Tile do
      result :=  IntToStr(Zoom) + '_' + FloatToStr(TileX) + '_' + FloatToStr(TileY);
  End;

//@002+ End of Insertion

// Returns tile number triplet in such a way as to be conducive to use for a
// file name
Function omGetFileTileNumber(const Lat:Real; const Lon:Real;
                             const Zoom:Integer):String;   overload;     //@002=
  var
   x:Integer;
   y:real;
  begin
    X := omGetTileX(Lat, Lon, Zoom);
    Y := omGetTileY(Lat, Lon, Zoom);
    result :=  inttostr(zoom) + '_' + FloatToStr(x) + '_' + FloatToStr(y);
  end;

//@002+ End of Insertion

// Gets a tile ID String for a URL.
Function omGetURLTileNumber(const Lat:Real; const Lon:Real;              //@002=
                            const Zoom:Integer):String;  overload;       //@002=
//  Const                                                                //@002-
//    PI = 3.14159;                                                      //@002-
  var
   x:Integer;                                                            //@002=
   y:real;                                                               //@002=
  begin
//   x := Floor((lon + 180) / 360 * Power(2, Zoom));                     //@002-
   X := omGetTileX(Lat, Lon, Zoom);                                      //@002+
//   y := Floor( (1 - ln(Tan(lat * PI / 180)                             //@002-
//                        + 1 / Cos(lat * PI / 180))                     //@002-
//                             / PI) / 2 * Power(2, Zoom));              //@002-
    Y := omGetTileY(Lat, Lon, Zoom);                                     //@002+
    result :=  inttostr(zoom) + '/' + FloatToStr(x) + '/' + FloatToStr(y);
  end;

// Returns the URL for a tile at a particular location and zoom level
Function omGetTileURL(const Lat:Real; const Lon:Real; const Zoom:Integer):String;
  begin
   result := 'http://tile.openstreetmap.org/'
     + omGetURLTileNumber(lat, lon, zoom) + '.png'
  end; // of Function

Function omGetTileURL(const Tile:TOSMTile):String; overload;
// Gets tile URL, given tile coordinates
  begin
   result := 'http://tile.openstreetmap.org/'
     + omGetURLTileNumber(Tile) + '.png'
  end; // of Function


Function omGetStaticMapURL(const Lat:Real; const Lon:Real; const Zoom:Integer):String;
  const
    protocol = 'http://';                                                //@002+
 //   HostName = 'old-dev.openstreetmap.org';                              //@002+
    HostName = 'ojw.dev.openstreetmap.org';
//    BaseURL  = '/~ojw/StaticMap';                                        //@002+
    BaseURL  = '/StaticMap';
  begin
    Result := Protocol + HostName + BaseURL + '/?'                       //@002=
    + 'lat=' + FloatToStr(lat)
    + '&lon='+ FloatToStr(lon)
    + '&z=' + IntToStr(Zoom)
//    + '&att=' + 'logo'  // or text or none
    + '&att=' + 'none'  // or text or none
    + '&fmt=' + 'png' // or jpg
// optional marker
    + '&mlat0=' +  FloatToStr(lat)
    + '&mlon0=' + FloatToStr(lon)
    + '&mico0=' + '0' // the icon, 0 = bullseye
// Show = 1 for image, 0 for HTML page
    + '&layer=cloudmade_2&mode=Location&show=1';
  end;

function StringToHash(const text:string):STRING;
//VAR output : TMD5Digest;
// The MD5Digest is actually 16 bytes long,
// Which means it should be 32 characters when represented in ASCII
begin
  result := mdprint(md5string(text));
end;

//@002+ Begin of Insertion
 Function omGetTileFileName(const Lat:Real; const Lon:Real;
                            const Zoom:Integer):String;
// Private Function to get tile name  (computes filename only)
// Doesn't download the file or check it's existance, etc.
   Begin
    Result := CacheRoot                                                  //@003=
             + omGetFileTileNumber(Lat, Lon, Zoom) + '.png';
   End;

 Function omGetTileFileName(const Tile:TOSMTile):String;  Overload;
// Private Function to get tile name  (computes filename only)
// Doesn't download the file or check it's existance, etc.
   Begin
    Result := CacheRoot                                                  //@003=
             + omGetFileTileNumber(Tile) + '.png';
   End;

 Function omTileCacheCheck(const FileName:String):Boolean;
// Returns True is cached (exists), False if not.
   Begin
    Result := FileExists(FileName);
   End;

Function URLDownload(const URL:String; const FullPath:String):Boolean;
// Downloads the specified URL to the complete path given.
// Returns true if no problems, false if it couldn't download.
    Var
      FileStream:TMemoryStream;
    Begin
      FileStream := TMemoryStream.Create;
        Try
          If not HttpGetBinary(URL, FileStream) then
            Result := False
          Else
             Begin
               FileStream.SaveToFile(FullPath);
               result := True;
             end;
         finally
           FileStream.Free;
         end;   // of TRY..FINALLY
    end;  // of FUNCTION

Function omGetTileFile(Const Tile:TOSMTile):String;   overload;
// Gives a pointer to the file name containing the desired tile, given by
// an actual tile structure (i.e. no lookup required).
   var
    TileURL:String;
    filename:String;
  Begin
     Result := '';
     TileURL := omGetTileURL(Tile);
     If TileURL = '' then
       Exit;
     FileName := omGetTileFileName(Tile);
     If omTileCacheCheck(FileName) then
       Result := Filename                     // We already have it, just return
     else                                     // We don't have it, we'll have to
       Begin                                  // Download it...
           If Not URLDownload(TileURL, FileName) then
             Result := ''
           Else
               result := FileName;
       end;// of IF Not (InCache)

  end;

//@002+ End of Insertion

Function omGetTileFile(const Lat:Real; const Lon:Real;
                        const Zoom:Integer):String;        overload;     //@002=
   var
    TileURL:String;
    filename:String;
//    ImageStream:TMemoryStream;                                         //@002-
   begin
     Result := '';
     TileURL := omGetTileURL(lat, lon, Zoom);
     If TileURL = '' then
       Exit;
//@002 Begin of Insertion
     FileName := omGetTileFileName(Lat, Lon, Zoom);
     If omTileCacheCheck(FileName) then
       Result := Filename                     // We already have it, just return
     else                                     // We don't have it, we'll have to
       Begin                                  // Download it...
//@002 End of Insertion
//       ImageStream := TMemoryStream.Create;                            //@002-
//         Try                                                           //@002-
//           If not HttpGetBinary(TileURL, ImageStream) then
           If Not URLDownload(TileURL, FileName) then
//             Exit                                                      //@002-
             Result := ''                                                //@002+
           Else
//             Begin                                                     //@002-
//             FileName := '/Users/shiruba/Library/OpenStreetMap/'       //@002-
//               + omGetFileTileNumber(Lat, Lon, Zoom) + '.png';         //@002-
//               ImageStream.SaveToFile(FileName);                       //@002-
               result := FileName;                                       //@002+
//             end;                                                      //@002-
//       finally                                                         //@002-
//           ImageStream.Free;                                           //@002-
//       end;                                                            //@002-
       end;// of IF Not (InCache)                                        //@002+
   end;   // of FUNCTION

// Converts a Tile into the NW corner's longitude
Function omTile2Long(Const Tile:TOSMTile):Real;                          //@003+
Begin
  With Tile do
    Result :=  TileX / Power(2.0, Zoom) * 360.0 - 180;
End; //

// Converts a Tile into the NW corner's latitude
Function omTile2Lat(Const Tile:TOSMTile):Real;                          //@003+
CONST
 PI = 3.14159;
var
 n:real;
Begin
  With Tile do
   begin
    n := PI - 2.0 * PI * TileY / Power(2.0, Zoom);
    Result :=  180.0 / PI * ArcTan(0.5 * (exp(n) - exp(-n)));

   end;
End; //

// Returns the X Position of the map marker relative to the tile on the screen,
// Given the current tile, and the latitude and longitude of the actual point
// of interest.
Function MarkerX(Const Tile:TOSMTile;
                 Const Lat:Real; Const Long:Real):Integer;               //@003+
Var
 TileNW_Lat:Real;
 TileNW_Long:Real;
 TileSE_Lat:Real;
 TileSE_Long:Real;
 TileSE:TOSMTile;
 Range_Lat:Real;
 Range_Long:Real;
 Normalized_Lat:Real;
 Normalized_Long:Real;
Begin
// First, get the NW corner
 TileNW_Lat := omTile2Lat(Tile);
 TileNW_Long := omTile2Long(Tile);
//Create a tile to the SE of this one
 TileSE := Tile;
 Inc(TileSE.TileX);
 Inc(TileSE.TileY);
// Calculate that tile's NW corner, which is the same as the SE corner of the
// tile we really want.
 TileSE_Lat := omTile2Lat(TileSE);
 TileSE_Long := omTile2Long(TileSE);
// Calculate the range at this zoom level in the current tile.
 Range_Lat := Abs(TileSE_Lat - TileNW_Lat);
 Range_Long := Abs(TileSE_Long - TileNW_Long);
// Calculated a normalize Lat and Long value, setting the NW corner of the
// current tile to (0,0)
 Normalized_Lat := Abs(Lat - TileNW_lat);
 Normalized_Long := Abs(Long - TileNW_long);
// Finally, calculate the result using proportions
 Result := Floor((Normalized_long  * 256 ) / Range_Long);

// NL   X
// __ = __
// RL   256

End;

Function MarkerY(Const Tile:TOSMTile;
                 Const Lat:Real; Const Long:Real):Integer;               //@003+
Var
 TileNW_Lat:Real;
 TileNW_Long:Real;
 TileSE_Lat:Real;
 TileSE_Long:Real;
 TileSE:TOSMTile;
 Range_Lat:Real;
 Range_Long:Real;
 Normalized_Lat:Real;
 Normalized_Long:Real;
Begin
// First, get the NW corner
 TileNW_Lat := omTile2Lat(Tile);
 TileNW_Long := omTile2Long(Tile);
//Create a tile to the SE of this one
 TileSE := Tile;
 Inc(TileSE.TileX);
 Inc(TileSE.TileY);
// Calculate that tile's NW corner, which is the same as the SE corner of the
// tile we really want.
 TileSE_Lat := omTile2Lat(TileSE);
 TileSE_Long := omTile2Long(TileSE);
// Calculate the range at this zoom level in the current tile.
 Range_Lat := Abs(TileSE_Lat - TileNW_Lat);
 Range_Long := Abs(TileSE_Long - TileNW_Long);
// Calculated a normalize Lat and Long value, setting the NW corner of the
// current tile to (0,0)
 Normalized_Lat := Abs(Lat - TileNW_lat);
 Normalized_Long := Abs(Long - TileNW_long);
// Finally, calculate the result using proportions
 Result := Floor((Normalized_lat  * 256 ) / Range_Lat);

// NL   X
// __ = __
// RL   256

End;

initialization                                                           //@003+

 CacheRoot := GetEnvironmentVariable('HOME');
// CacheRoot := CacheRoot + '/Library/OpenStreetMap';
CacheRoot := CacheRoot + '/Library';
 SetDirSeparators(CacheRoot);
 If not DirectoryExists(CacheRoot) then
  CreateDir(CacheRoot);
  CacheRoot := CacheRoot + '/OpenStreetMap';
   If not DirectoryExists(CacheRoot) then
  CreateDir(CacheRoot);

 CacheRoot := CacheRoot + '/';
 SetDirSeparators(CacheRoot);
end. // of UNIT

