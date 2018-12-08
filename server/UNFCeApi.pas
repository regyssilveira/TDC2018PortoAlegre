unit UNFCeApi;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/api')]
  TNFCeApi = class(TMVCController)
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutos;

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProduto(id: string);

    [MVCPath('/nfce')]
    [MVCHTTPMethod([httpGET])]
    procedure GetNFCe;

    [MVCPath('/nfce')]
    [MVCHTTPMethod([httpPOST])]
    procedure EnviarNFCe(Context: TWebContext);
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, UNFCeWebModule,
  Data.DB, UNFCe, DNFCe;

procedure TNFCeApi.Index;
begin
  //use Context property to access to the HTTP request and response
  Render('<h1>TDC Porto Alegre - 2018</h1>');
end;

procedure TNFCeApi.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TNFCeApi.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

procedure TNFCeApi.GetProdutos;
var
  Wm: TNFCeWebmodule;
  TmpDataset: TDataset;
begin
  Wm := GetCurrentWebModule as TNFCeWebmodule;
  Wm.FDConnection1.ExecSQL(
    'select * from produtos',
    TmpDataset
  );

  Render(TmpDataset);
end;

procedure TNFCeApi.GetProduto(id: string);
var
  Wm: TNFCeWebmodule;
  TmpDataset: TDataset;
begin
  if id.Trim.IsEmpty then
    raise Exception.Create('Código do produto não foi informado');

  if StrToIntDef(Id, -1) <= 0 then
    raise Exception.Create('Código do produto inválido');

  Wm := GetCurrentWebModule as TNFCeWebmodule;
  Wm.FDConnection1.ExecSQL(
    'select * from produtos where id=' + id,
    TmpDataset
  );

  Render(TmpDataset);
end;

procedure TNFCeApi.GetNFCe;
var
  NFCe: TNFCe;
  NFCeItem: TNFCeItem;
begin
  NFCe := TNFCe.Create;
  NFCe.cpf := '84915170659';
  NFCe.Nome := 'regys';

  NFCeItem := TNFCeItem.Create;
  NFCeItem.id := 1;
  NFCeItem.descricao := 'teste';
  NFCeItem.valor := 1.23;
  NFCe.Itens.Add(NFCeItem);

  NFCeItem := TNFCeItem.Create;
  NFCeItem.id := 3;
  NFCeItem.descricao := 'teste2';
  NFCeItem.valor := 3.23;
  NFCe.Itens.Add(NFCeItem);

  NFCeItem := TNFCeItem.Create;
  NFCeItem.id := 3;
  NFCeItem.descricao := 'teste3';
  NFCeItem.valor := 4.25;
  NFCe.Itens.Add(NFCeItem);

  Render(NFCe);
end;

procedure TNFCeApi.EnviarNFCe(Context: TWebContext);
var
  NFCe: TNFCe;
  DmNFCe: TdtmNFCe;
  StrRetorno: string;
begin
  NFCe := Context.Request.BodyAs<TNFCe>;
  DmNFCe := TdtmNFCe.Create(nil);
  try
    try
      DmNFCe.PreencherNFCe(NFCe);
      StrRetorno := DmNFCe.Enviar;

      Render(201, StrRetorno);
    except
      on E: Exception do
      begin
        Render(500, E.Message);
      end;
    end;
  finally
    NFCe.Free
  end;
end;

end.
