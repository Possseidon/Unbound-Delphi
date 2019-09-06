object frmTab: TfrmTab
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object tvExplorer: TTreeView
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    Images = dmData.ilIcons
    Indent = 19
    TabOrder = 0
    OnCreateNodeClass = tvExplorerCreateNodeClass
    OnEditing = tvExplorerEditing
  end
end
