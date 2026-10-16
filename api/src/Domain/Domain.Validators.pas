unit Domain.Validators;

interface

type
  TValidators = class
  public
    class function IsValidEAN13(const AEAN: string): Boolean;
    class function IsValidSKU(const ASKU: string): Boolean;
  end;

implementation

uses
  System.SysUtils, System.RegularExpressions;

{ TValidators }

class function TValidators.IsValidEAN13(const AEAN: string): Boolean;
var
  I, LSum, LCheck: Integer;
begin
  if AEAN.IsEmpty then
    Exit(True);

  if Length(AEAN) <> 13 then
    Exit(False);

  for I := 1 to Length(AEAN) do
    if not CharInSet(AEAN[I], ['0'..'9']) then
      Exit(False);

  LSum := 0;
  for I := 1 to 12 do
  begin
    if Odd(I) then
      LSum := LSum + StrToInt(AEAN[I])
    else
      LSum := LSum + StrToInt(AEAN[I]) * 3;
  end;

  LCheck := (10 - (LSum mod 10)) mod 10;
  Result := LCheck = StrToInt(AEAN[13]);
end;

class function TValidators.IsValidSKU(const ASKU: string): Boolean;
begin
  if ASKU.IsEmpty then
    Exit(False);

  Result := TRegEx.IsMatch(ASKU, '^[A-Z0-9\-]{3,20}$');
end;

end.
