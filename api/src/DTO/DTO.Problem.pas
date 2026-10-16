unit DTO.Problem;

interface

uses
  System.JSON;

type
  TProblemDetail = record
    &Type: string;
    Title: string;
    Status: Integer;
    Detail: string;
    Errors: TArray<string>;
    function ToJSON: TJSONObject;
  end;

implementation

{ TProblemDetail }

function TProblemDetail.ToJSON: TJSONObject;
var
  LErrors: TJSONArray;
  LMsg: string;
begin
  Result := TJSONObject.Create;
  Result.AddPair('type', &Type);
  Result.AddPair('title', Title);
  Result.AddPair('status', TJSONNumber.Create(Status));
  Result.AddPair('detail', Detail);

  LErrors := TJSONArray.Create;
  for LMsg in Errors do
    LErrors.Add(LMsg);
  Result.AddPair('errors', LErrors);
end;

end.
