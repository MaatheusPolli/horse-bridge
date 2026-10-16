unit Middleware.Logger;

interface

uses
  Horse;

type
  TMiddlewareLogger = class
  public
    class procedure Execute(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  System.SysUtils, System.DateUtils, System.Diagnostics;

{ TMiddlewareLogger }

class procedure TMiddlewareLogger.Execute(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LSw: TStopwatch;
  LMethod, LPath: string;
  LStatus: Integer;
begin
  LSw := TStopwatch.StartNew;
  LMethod := Req.RawWebRequest.Method;
  LPath := Req.RawWebRequest.PathInfo;

  try
    Next;
  finally
    LSw.Stop;
    LStatus := Res.RawWebResponse.StatusCode;
    Writeln(Format('{"timestamp":"%s","method":"%s","path":"%s","status":%d,"duration_ms":%d}',
      [FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', TTimeZone.Local.ToUniversalTime(Now)),
       LMethod, LPath, LStatus, LSw.ElapsedMilliseconds]));
  end;
end;

end.
