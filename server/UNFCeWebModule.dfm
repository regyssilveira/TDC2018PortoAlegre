object NFCeWebmodule: TNFCeWebmodule
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <>
  Height = 471
  Width = 641
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=C:\Users\regys\Desktop\ACBrDay\bin\dados.sqlite'
      'DriverID=SQLite')
    LoginPrompt = False
    BeforeConnect = FDConnection1BeforeConnect
    Left = 75
    Top = 50
  end
  object qryProdutos: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from produtos')
    Left = 75
    Top = 130
  end
end
