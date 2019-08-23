unit UBSExplorer.DataModule;

interface

uses
  System.ImageList,
  System.Classes,

  Vcl.Dialogs,
  Vcl.ImgList,
  Vcl.Controls;

type
  TdmData = class(TDataModule)
    ilIcons: TImageList;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
  private
  end;

var
  dmData: TdmData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
