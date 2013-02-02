unit debug;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs;

procedure OutString (s : string);

implementation
uses ui;

procedure OutString (s : string);
begin
   ui.Form1.Memo1.Lines.Add(s);
   writeln(s);
   Application.ProcessMessages;
end;

end.

