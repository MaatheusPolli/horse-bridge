unit Infra.Connection;

interface

uses
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.DApt;

type
  TConnectionFactory = class
  private
    class var FConnection: TFDConnection;
  public
    class procedure Initialize(const ADbPath: string);
    class function GetConnection: TFDConnection;
    class procedure Finalize;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

{ TConnectionFactory }

class procedure TConnectionFactory.Initialize(const ADbPath: string);
var
  LDir: string;
begin
  LDir := ExtractFilePath(ADbPath);
  if (LDir <> '') and not TDirectory.Exists(LDir) then
    TDirectory.CreateDirectory(LDir);

  FConnection := TFDConnection.Create(nil);
  FConnection.DriverName := 'SQLite';
  FConnection.Params.Database := ADbPath;
  FConnection.Params.Values['LockingMode'] := 'Normal';
  FConnection.Params.Values['JournalMode'] := 'WAL';
  FConnection.LoginPrompt := False;
  FConnection.Connected := True;

  FConnection.ExecSQL('PRAGMA foreign_keys = ON');
end;

class function TConnectionFactory.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

class procedure TConnectionFactory.Finalize;
begin
  FreeAndNil(FConnection);
end;

end.
