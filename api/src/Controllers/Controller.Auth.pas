unit Controller.Auth;

interface

type
  TControllerAuth = class
  public
    class procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  Horse,
  App.Container;

{ TControllerAuth }

class procedure TControllerAuth.RegisterRoutes;
begin
  THorse.Post('/auth/login',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LBody: TJSONObject;
      LUsername, LPassword: string;
      LResult: TJSONObject;
    begin
      LBody := Req.Body<TJSONObject>;
      LBody.TryGetValue<string>('username', LUsername);
      LBody.TryGetValue<string>('password', LPassword);

      LResult := TContainer.GetInstance.AuthService.Login(LUsername, LPassword);
      Res.Send<TJSONObject>(LResult);
    end);
end;

end.
