unit UPrincipal;

interface

uses
  MVCFramework.RESTClient,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView, FireDAC.Comp.DataSet,
  IPPeerClient, FMX.Edit, FMX.ListBox,
  Data.Bind.ObjectScope, FireDAC.Stan.StorageBin;

type
  TForm2 = class(TForm)
    tbVenda: TFDMemTable;
    tbVendaId: TIntegerField;
    tbVendaDescricao: TStringField;
    tbVendaValor: TFloatField;
    tbVendaQuantidade: TIntegerField;
    ListView1: TListView;
    btnEnviar: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    Venda: TGroupBox;
    tbListaProdutos: TFDMemTable;
    CbxProduto: TComboBox;
    Produto: TLabel;
    edtQuantidade: TEdit;
    Label1: TLabel;
    edtNumeroNota: TEdit;
    Label2: TLabel;
    btnAdicionar: TButton;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    tbListaProdutosid: TIntegerField;
    tbListaProdutosdescricao: TStringField;
    tbListaProdutosvalor: TFloatField;
    Produtos: TButton;
    edtNome: TEdit;
    Label3: TLabel;
    edtCPF: TEdit;
    Label4: TLabel;
    procedure btnEnviarClick(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ProdutosClick(Sender: TObject);
    procedure tbListaProdutosAfterOpen(DataSet: TDataSet);
  private
    Clt: TRESTClient;
  public

  end;

var
  Form2: TForm2;

implementation

uses
  UNFCe, MVCFramework.DataSet.Utils;

{$R *.fmx}

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Clt.Free;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  tbVenda.CreateDataSet;
  //Clt := TRESTClient.Create('http://127.0.0.1', 8080);
  Clt := TRESTClient.Create('http://172.16.0.175', 8080);
end;

procedure TForm2.tbListaProdutosAfterOpen(DataSet: TDataSet);
var
  Res: IRESTResponse;
begin
  Res := Clt.doGET('/api/produtos', []);
  if Res.HasError then
  begin
    ShowMessage(Res.ResponseText);
    Exit;
  end;

  DataSet.DisableControls;
  try
    tbListaProdutos.LoadFromJSONArrayString(Res.BodyAsString);
    tbListaProdutos.First;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TForm2.btnAdicionarClick(Sender: TObject);
begin
  tbVenda.Append;
  tbVendaId.Value         := tbListaProdutosid.AsInteger;
  tbVendaDescricao.Value  := tbListaProdutosdescricao.AsString;
  tbVendaValor.Value      := tbListaProdutosvalor.AsFloat;
  tbVendaQuantidade.Value := StrToInt(edtQuantidade.Text);
  tbVenda.Post;

  ShowMessage('Item adicionado!');
end;

procedure TForm2.btnEnviarClick(Sender: TObject);
var
  Res: IRESTResponse;
  NFCe: TNFCe;
  NFCeItem: TNFCeItem;
begin
  NFCe := TNFCe.Create;
  try
    NFCe.cpf    := edtCPF.Text;
    NFCe.Nome   := edtNome.Text;
    NFCe.Numero := edtNumeroNota.Text.ToInteger;

    tbVenda.First;
    while not tbVenda.Eof do
    begin
      NFCeItem := TNFCeItem.Create;
      NFCeItem.Id         := tbVendaId.Value;
      NFCeItem.Descricao  := tbVendaDescricao.Value;
      NFCeItem.Valor      := tbVendaValor.Value;
      NFCeItem.Quantidade := tbVendaQuantidade.Value;

      NFCe.Itens.Add(NFCeItem);

      tbVenda.Next;
    end;

    Res := Clt.doPOST('/api/nfce', [], NFCe.AsJsonString);
    if Res.HasError then
    begin
      ShowMessage(Res.ResponseText);
      Exit;
    end;

    ShowMessage('Venda enviada.');

    tbVenda.Close;
    tbVenda.CreateDataSet;
  finally
    NFCe.Free;
  end;
end;

procedure TForm2.ProdutosClick(Sender: TObject);
begin
  tbListaProdutos.Open;
end;

end.
