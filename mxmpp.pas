unit mxmpp;

{$mode objfpc}
//{$mode delphi}
{$H+}

interface

uses
  Classes, SysUtils;
const meridian_res = 'meridian23';
      coord_request = 'coordinates please';
      not_sharing = 'not sharing';
procedure Open(username, password, port : string);
procedure Close;
function IsLoggedIn(): boolean;
procedure send_message(jid, msg_text : string);

implementation

uses gpspipe, openmap, dialogs, ui, uxmpp, debug, synautil, libxmlparser, strutils, maint, base64, graphics, extctrls, contacts;

const play_sound_program = '/usr/bin/play-sound';
      online_sound = '/opt/meridian23/sounds/online.wav';
      offline_sound = '/opt/meridian23/sounds/offline.wav';

var last_requested_photo_hash : string = '';


type TXmpp0 = class(Txmpp)
   private
    procedure DoOnError(Sender:TObject;Value:string);
    procedure DoOnLoggin(Sender:TObject);
    procedure DoOnLogout(Sender:TObject);
    procedure DoOnDebugXML(Sender:TObject;Value:string);
    procedure DoOnMsg(Sender:TObject;From,MsgText,MsgHTML:string;
      TimeStamp:TDateTime;MsgType:TMessageType);
    procedure DoOnJoinedRoom(Sender:TObject;JID:string);
    procedure DoOnLeftRoom(Sender:TObject;JID:string);
    procedure DoOnRoster(Sender:TObject;JID,Name_,Subscription,Group:string);
    procedure DoOnPresence(Sender: TObject; presence_type_, jid_, resource_, status_, photo_: string);
    procedure DoOnIqVcard(Sender:TObject; from_, to_, fn_, photo_type_, photo_bin_ : string);
  end;
var xmpp:TXmpp0;
    logged_in : boolean = false ;
    //request_sent : boolean = false; //temporary for debug

   procedure send_message(jid, msg_text : string);
   begin
   xmpp.SendPersonalMessage(jid, msg_text);
   end;

   procedure  play_sound_online;
   begin
      if sysutils.FileExists(play_sound_program) and sysutils.fileexists (online_sound) then begin
          sysutils.ExecuteProcess(play_sound_program, online_sound,[]);
      end;
   end;

   procedure  play_sound_offline;
   begin
      if sysutils.FileExists(play_sound_program) and sysutils.fileexists (offline_sound) then begin
          sysutils.ExecuteProcess(play_sound_program, offline_sound,[]);
      end;
   end;


    function ChooseGraphicClass(const MimeType: string): TGraphicClass;
    begin
      if MimeType = 'image/bmp' then
        Result := TBitmap
      else if MimeType = 'image/png' then
        Result :=  TPortableNetworkGraphic//TPngImage
      else if MimeType = 'image/gif' then
        Result := TGifImage
      else if MimeType = 'image/jpeg' then
        Result := TJpegImage
      else
        debug.OutString ('unknown image format');
        //raise //EUnknownGraphicFormat.Create(MimeType);
    end;

Function StringToStream(const AString: string): TStream;
begin
  Result := TStringStream.Create(AString);
end;

function CreateGraphicFromVCardPhoto(const BinVal, MimeType: string): TGraphic;
var
  Stream: TStream;
  GraphicClass: TGraphicClass;
  s : string;
begin
  //Stream := TMemoryStream.Create;
  try
  //  if not Base64Decode(BinVal, Stream) then
  //    raise EBase64Decode.Create;
    s := base64.DecodeStringBase64(Binval);
    Stream := StringToStream(s);

    Stream.Position := 0;
    GraphicClass := ChooseGraphicClass(MimeType);
    Result := GraphicClass.Create;
    try
      Result.LoadFromStream(Stream);
    except
      Result.Free;
      raise;
    end;
  finally
    Stream.Free;
  end;
end;

procedure SaveBase64ToFile(const encoded, hash: string; file_type : TGraphicClass);
   var fs: TFileStream;
      stream : TStream;
      Decoder: TBase64DecodingStream;
      EncodedStream, DecodedStream: TStringStream;

        s, fileName: string;
       // f : textfile;
begin
  if file_type = TBitMap then s := '.bmp'
  else if file_type = TPortableNetworkGraphic then s := '.png'
  else if file_type = TGifImage then s := '.gif'
  else if file_type = TJpegImage then s := '.jpg'
  else s := '';
      // writeln ('unsupported avatar format');
  if s <> '' then begin
     debug.OutString('encoded string length is ' + inttostr(length(encoded)));
     fileName := maint.avadir + DirectorySeparator + hash + s;

     EncodedStream := TStringStream.Create(encoded);
     EncodedStream.Position:=0;
         debug.OutString('encoded stream size is ' + inttostr(EncodedStream.Size));
     Decoder := TBase64DecodingStream.Create(EncodedStream, bdmMIME{bdmStrict});
  //   Decoder.Position:=0;
     debug.OutString('decoded stream size is ' + inttostr(Decoder.Size));
     fs := TFileStream.Create(fileName, fmCreate);
     fs.CopyFrom(Decoder, Decoder.Size);
     debug.OutString('file stream size is ' + inttostr(fs.Size));
     FreeAndNil(fs);

     EncodedStream.Free;
     Decoder.Free;



     //s := base64.DecodeStringBase64(encoded);
     //stream := StringToStream(s);
     //stream.Position:= 0;;
     //fs.CopyFrom(StringToStream(s), stream.Size);
     //FreeAndNil(fs);
     {assignfile (f, fileName);
     rewrite(f);
     writeln (f, s);
     closefile(f);}
  end;
end;

procedure SendAvatarRequest(xmpp : TXmpp0; contact, avatar : string);
  var request : string;
      user_ : string;
begin
 // if not request_sent then begin
  debug.OutString('generate avatar request:');
  user_ := strutils.Copy2Symb(contact, '/');
  //vcard approach
//  request := '<iq from=' + #39 + xmpp.JabberID + '/' + xmpp.Resource + #39 + ' to=' + #39 + user_ + #39 + ' type=''get'' id=''vc2''> <vCard xmlns=''vcard-temp''/> </iq>';
  //the same without from field
    request := '<iq to=' + #39 + user_ + #39 + ' type=''get'' id=''vc2''> <vCard xmlns=''vcard-temp''/> </iq>';
  xmpp.SendCommand(request);
  last_requested_photo_hash := avatar;
 // request_sent := true;
//  end; //if not request_sent
end;

procedure Txmpp0.DoOnError(Sender:TObject;Value:string);
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnError');
     debug.OutString('');
     debug.OutString(Value);
     debug.OutString('');
     debug.OutString('Exited DoOnError');
     debug.OutString('');
   end;

   procedure Txmpp0.DoOnLoggin(Sender:TObject);
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnLogging');
     debug.OutString('');
     debug.OutString('Exited DoOnLogging');
     debug.OutString('');
     logged_in := true;
   end;

   procedure Txmpp0.DoOnLogout(Sender:TObject);
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnLogout');
     debug.OutString('');
     debug.OutString('Exited DoOnLogout');
     debug.OutString('');
     logged_in := false;
   end;

   procedure fix_coord(var s :string);
   var i : integer;
       begin
         i := 1;
         repeat
            if s[i] = ',' then s[i] := '.';
           inc(i)
         until i = length(s) ;
       end;

   procedure Txmpp0.DoOnDebugXML(Sender:TObject;Value:string);
   var Parser : libxmlparser.TXmlParser;
       str, name_, value_, contact_jid, full_name, image_type, image_binval : string;
       i : integer;
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnDebugXML');
     debug.OutString('');
     debug.OutString(Value);
     debug.OutString('');
     debug.OutString('');
     debug.OutString('Exited DoOnDebugXML');
     debug.OutString('');
   end;  //DoOnDebugXML

   procedure Txmpp0.DoOnMsg(Sender:TObject;From,MsgText,MsgHTML:string;
     TimeStamp:TDateTime;MsgType:TMessageType);
   var jid_,  res_, longit, latid : string;
       rlon, rlat : real;
     //  path_to_file : string;
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnMsg');
     debug.OutString('');
     debug.OutString('From:');
     debug.OutString(From);
     debug.OutString('');
     debug.OutString('MsgText:');
     debug.OutString(MsgText);
     debug.OutString('');
     debug.OutString('MsgHTML:');
     debug.OutString('MsgHTML');
     debug.OutString('');
     debug.OutString('TimeStamp:');
     debug.OutString('');
     debug.OutString(DateTimeToStr(TimeStamp));
     debug.OutString('');
     debug.OutString('MsgType:');
     case MsgType of
        mtRoom: debug.OutString('ROOM MSG');
        mtPersonal:debug.OutString('PERSONAL MSG');
     end;

     {
From:
nemrout@googlemail.com/meridian2314C0A12C
MsgText:
lon=3;lat=5

     }
     jid_ := synautil.SeparateLeft(From, '/');
     res_ := synautil.SeparateRight(From, '/');
  if Copy(res_, 1, 10) = meridian_res then begin

     if MsgText = coord_request then begin
             if ui.Form1.MyGPSThread <> nil then begin

                if ui.Form1.MyGPSThread.Terminated = false then begin
                   //if (ui.Form1.MyGPSThread.fStatusText = fGPSFixed)  or (ui.Form1.MyGPSThread.fStatusText = fGPSUpdated) then begin
                   if (ui.Form1.Button2.Enabled) and (ui.Form1.Button2.Caption = 'Stop') then begin;
                        if ui.sharing then begin
                           longit := ui.Form1.MyGPSThread.longitude;
                           latid   := ui.Form1.MyGPSThread.latitude;
                           fix_coord(longit);
                           fix_coord(latid);
                           send_message(From, 'lon=' + longit + ';' + 'lat=' + latid);
                        end
                       else
                        begin
                           send_message(From, not_sharing);
                        end;
                   end
                  else
                   begin
                           send_message(From, not_sharing);
                   end;
                end
                else
                begin //gps not running
                send_message(From, not_sharing);

                end;

             end
             else
             begin //gps not running
                send_message(From, not_sharing);
             end;
     end
     else
     begin

      if MsgText = not_sharing then begin
             dialogs.ShowMessage('the peer ' + jid_ + ' has''nt enable location sharing');
      end
      else
      begin //if the peer shares info
         longit:= synautil.SeparateLeft(MsgText, ';');
         longit := synautil.SeparateRight(longit, '=');

         latid := synautil.SeparateRight(MsgText, ';');
         latid := synautil.SeparateRight(latid, '=');
          fix_coord(latid);
          fix_coord(longit);
          rlon := sysutils.StrToFloat(longit);
          rlat := SysUtils.StrToFloat(latid);
         Contacts.UpdateCoords(jid_, longit, latid);
                 //omGetTileFile(const Lat:Real; const Lon:Real;                   //@002+
                   //    const Zoom:Integer):String;
//
         ui.OpenContactImage(jid_, rlat, rlon);
       end;
     end;
   end; //if sent from meridian device
  end;

   procedure Txmpp0.DoOnJoinedRoom(Sender:TObject;JID:string);
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnJoinedRoom');
     debug.OutString('');
     debug.OutString('');
     debug.OutString('');
     debug.OutString('Exited DoOnJoinedRoom');
     debug.OutString('');
   end;

   procedure Txmpp0.DoOnLeftRoom(Sender:TObject;JID:string);
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnLeftRoom');
     debug.OutString('');
     debug.OutString('');
     debug.OutString('');
     debug.OutString('Exited DoOnLeftRoom');
     debug.OutString('');
   end;

   procedure Txmpp0.DoOnRoster(Sender:TObject;JID,Name_,Subscription,Group:string);
   begin
     debug.OutString('');
     debug.OutString('Entered DoOnRoster');
     debug.OutString('');
     debug.OutString('JID:');
     debug.OutString(JID);
     debug.OutString('');
     debug.OutString('Name:');
     debug.OutString(Name_);
     debug.OutString('');
     debug.OutString('Subscription');
     debug.OutString(Subscription);
     debug.OutString('');
     debug.OutString('Group:');
     debug.OutString(Group);
     debug.OutString('');
   end;


   procedure TXmpp0.DoOnIqVcard(Sender:TObject; from_, to_, fn_, photo_type_, photo_bin_ : string);
      var grclass : TGraphicClass;
          image : TImage;
          graphic : TGraphic;
   begin
       debug.OutString('Entered DoOnIqVcard');
       debug.OutString(from_);
       debug.OutString(to_);
       debug.OutString(photo_type_);
       debug.OutString(photo_bin_);
       //save avatar
       //grclass := ChooseGraphicClass(photo_type_);
       //SaveBase64ToFile(photo_bin_,last_requested_photo_hash, grclass);
       {graphic := CreateGraphicFromVCardPhoto(photo_bin_, photo_type_);
       image := TImage.Create();
       image.Picture.Graphic := graphic;}
       debug.OutString('Exited DoOnIqVcard');

   end;

   procedure Txmpp0.DoOnPresence(Sender: TObject; presence_type_, jid_, resource_, status_, photo_: string);
   var  ftype : graphics.TGraphicClass;
        fpath : string;
   begin

     debug.OutString('Entered DoOnPresence');
     debug.OutString('presence type is ' + presence_type_);
     debug.OutString('jid is ' + jid_);
     debug.OutString('resource is ' + resource_);
     debug.OutString('status is ' + status_);
     debug.OutString('photo is ' + photo_);
     debug.OutString('Exited DoOnPresence');
     //will return us file path and type by given hash

     if Copy(resource_, 1, 10) = meridian_res then begin
        if presence_type_ = 'unavailable' then begin
           Contacts.RemoveContact(jid_);
           play_sound_offline;
        end
        else // if available
        begin
          Contacts.AddContact(jid_, '', resource_);
          play_sound_online;
        end;
        ui.Form1.ListBox1.Items.Assign(Contacts.ContactList);

     end;

     {
     if (maint.check_is_photo_saved(photo_, fpath, ftype) = false) then begin
        if jid_ <> '' then begin
           // SendAvatarRequest(Self, jid_, photo_);
        end; //if contact is set
     end; // if photo does not exist locally
      }


   end;



procedure Open(username, password, port : string);
begin
  xmpp := TXmpp0.Create;
  xmpp.OnError := @xmpp.DoOnError;
  xmpp.OnDebugXML := @xmpp.DoOnDebugXML;
  xmpp.OnMessage := @xmpp.DoOnMsg;
  xmpp.OnUserJoinedRoom := @xmpp.DoOnJoinedRoom;
  xmpp.OnUserLeftRoom := @xmpp.DoOnLeftRoom;
  xmpp.OnLogin := @xmpp.DoOnLoggin;
  xmpp.OnLogout := @xmpp.DoOnLogout;
  xmpp.OnRoomList := @xmpp.DoOnDebugXML;
  xmpp.OnRoster := @xmpp.DoOnRoster;

  xmpp.OnPresence:= @xmpp.DoOnPresence;
  xmpp.OnIqVcard:= @xmpp.DoOnIqVcard;

  xmpp.Resource:= meridian_res;
  xmpp.Host := synautil.SeparateRight(username, '@');
  xmpp.Port := port;//'5222';
  xmpp.JabberID := username;//'username@gmail.com';
  xmpp.Password := password;
  xmpp.Login;
end; //Open

procedure Close;
begin
   xmpp.Logout;
end;

function IsLoggedIn(): boolean;
begin
  IsLoggedIn := logged_in;
end;

end.


