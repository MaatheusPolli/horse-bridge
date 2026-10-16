unit Middleware.ErrorHandler;

interface

uses
  Horse;

type
  TMiddlewareErrorHandler = class
  public
    class procedure Execute(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  System.SysUtils, System.JSON,
  Domain.Exceptions;

{ TMiddlewareErrorHandler }

class procedure TMiddlewareErrorHandler.Execute(Req: THorseRequest; Res: THorseResponse; Next: TProc);

  function BuildProblem(AStatus: Integer; const ATitle, ADetail: string;
    AErrors: TJSONArray = nil): TJSONObject;
  begin
    Result := TJSONObject.Create;
    Result.AddPair('type', 'about:blank');
    Result.AddPair('title', ATitle);
    Result.AddPair('status', TJSONNumber.Create(AStatus));
    Result.AddPair('detail', ADetail);
    if Assigned(AErrors) then
      Result.AddPair('errors', AErrors)
    else
      Result.AddPair('errors', TJSONArray.Create);
  end;

begin
  try
    Next;
  except
    on E: EValidationError do
    begin
      var LErrors := TJSONArray.Create;
      for var LMsg in E.Messages do
        LErrors.Add(LMsg);
      Res.Status(THTTPStatus.BadRequest)
         .ContentType('application/problem+json')
         .Send<TJSONObject>(BuildProblem(400, 'Validation Error', E.Message, LErrors));
    end;

    on E: ENotFoundError do
      Res.Status(THTTPStatus.NotFound)
         .ContentType('application/problem+json')
         .Send<TJSONObject>(BuildProblem(404, 'Not Found', E.Message));

    on E: EConflictError do
      Res.Status(THTTPStatus.Conflict)
         .ContentType('application/problem+json')
         .Send<TJSONObject>(BuildProblem(409, 'Conflict', E.Message));

    on E: EUnauthorizedError do
      Res.Status(THTTPStatus.Unauthorized)
         .ContentType('application/problem+json')
         .Send<TJSONObject>(BuildProblem(401, 'Unauthorized', E.Message));

    on E: Exception do
      Res.Status(THTTPStatus.InternalServerError)
         .ContentType('application/problem+json')
         .Send<TJSONObject>(BuildProblem(500, 'Internal Server Error', 'Erro inesperado'));
  end;
end;

end.
