unit Domain.Exceptions;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  EValidationError = class(Exception)
  private
    FMessages: TArray<string>;
  public
    constructor Create(const AMessages: TArray<string>); overload;
    constructor Create(const AMessage: string); overload;
    property Messages: TArray<string> read FMessages;
  end;

  ENotFoundError = class(Exception);
  EConflictError = class(Exception);
  EUnauthorizedError = class(Exception);

implementation

{ EValidationError }

constructor EValidationError.Create(const AMessages: TArray<string>);
begin
  FMessages := AMessages;
  if Length(AMessages) > 0 then
    inherited Create(AMessages[0])
  else
    inherited Create('Erro de validação');
end;

constructor EValidationError.Create(const AMessage: string);
begin
  FMessages := [AMessage];
  inherited Create(AMessage);
end;

end.
