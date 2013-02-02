unit maint;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

var confdir, avadir, mapdir : string;

procedure start;
function check_is_photo_saved(aphoto : string; var fpath : string; var ftype : Graphics.TGraphicClass ) : boolean;
implementation

function check_is_photo_saved(aphoto : string; var fpath : string; var ftype : Graphics.TGraphicClass ) : boolean;
   var nm : string;
     pth : string;
     ext : string;
begin
   check_is_photo_saved := false;
   pth := avadir + DirectorySeparator;
   ext := '.png';
   nm := aphoto + ext;
   fpath := pth + nm;
   if SysUtils.FileExists(pth + nm) then begin
      ftype := TPortableNetworkGraphic;
      check_is_photo_saved := true;
   end
  else
   begin
      ext := '.jpg';
      nm := aphoto + ext;
      fpath := pth + nm;
      if SysUtils.FileExists (fpath) then begin
          ftype := TJpegImage;
          check_is_photo_saved := true;
      end
     else
      begin
          ext := '.gif';
          nm := aphoto +  ext;
          fpath := pth + nm;
          if SysUtils.FileExists(fpath) then begin
             ftype := TGifImage;
             check_is_photo_saved := true;
          end
         else
             ext := '.bmp';
             nm  := aphoto + ext;
             fpath := pth + nm;
             if sysutils.FileExists(fpath) then begin
                ftype := TBitMap;
                check_is_photo_saved := true;
             end
            else
             begin
                check_is_photo_saved := false;
             end;
         end;
      end;
end;

procedure start;
begin
   confdir := SysUtils.GetAppConfigDir(false);
//   avadir  := confdir + DirectorySeparator + 'ava';
   avadir  := confdir + 'ava';
   mapdir  := confdir + 'maps';

   If Not DirectoryExists(confdir) then begin

       If Not CreateDir (confdir) Then begin
          Writeln ('Failed to create directory ' + confdir +  '!');
       end;
   end;

   If Not DirectoryExists(avadir) then begin

       If Not CreateDir (avadir) Then begin
          Writeln ('Failed to create directory ' +  avadir  + '!');
       end;
   end;

   If Not DirectoryExists(mapdir) then begin

       If Not CreateDir (mapdir) Then begin
          Writeln ('Failed to create directory ' +  avadir  + '!');
       end;
   end;


end;

end.

