unit Controller.Health;

interface

type
  TControllerHealth = class
  public
    class procedure RegisterRoutes;
  end;

implementation

uses
  System.SysUtils, System.JSON,
  Horse;

{ TControllerHealth }

class procedure TControllerHealth.RegisterRoutes;
begin
  THorse.Get('/health',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LJson: TJSONObject;
    begin
      LJson := TJSONObject.Create;
      LJson.AddPair('status', 'ok');
      LJson.AddPair('timestamp', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now));
      LJson.AddPair('version', '1.0.0');
      Res.Send<TJSONObject>(LJson);
    end);
end;

end.
