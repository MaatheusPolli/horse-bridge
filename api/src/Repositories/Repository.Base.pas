unit Repository.Base;

interface

uses
  FireDAC.Comp.Client;

type
  TBaseRepository = class
  protected
    FConn: TFDConnection;
    function NewQuery: TFDQuery;
  public
    constructor Create(AConn: TFDConnection);
  end;

implementation

{ TBaseRepository }

constructor TBaseRepository.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

function TBaseRepository.NewQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConn;
end;

end.
