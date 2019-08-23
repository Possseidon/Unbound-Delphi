object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'UBS-Explorer'
  ClientHeight = 385
  ClientWidth = 564
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object sbMain: TStatusBar
    Left = 0
    Top = 366
    Width = 564
    Height = 19
    Panels = <>
  end
  object tbMain: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 558
    Height = 22
    AutoSize = True
    DrawingStyle = dsGradient
    Images = dmData.ilIcons
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Caption = 'ToolButton1'
      ImageIndex = 0
      OnClick = ToolButton1Click
    end
  end
  object pcTabs: TPageControl
    AlignWithMargins = True
    Left = 3
    Top = 31
    Width = 558
    Height = 332
    Align = alClient
    TabOrder = 2
    OnChange = pcTabsChange
    OnMouseDown = pcTabsMouseDown
  end
  object mmMain: TMainMenu
    Left = 32
    Top = 64
    object File1: TMenuItem
      Caption = 'File'
      object New1: TMenuItem
        Caption = 'New'
        object NewMap1: TMenuItem
          Action = actNewMap
        end
        object NewList1: TMenuItem
          Action = actNewList
        end
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Open1: TMenuItem
        Action = actOpen
      end
      object Save2: TMenuItem
        Action = actSave
      end
      object Save1: TMenuItem
        Action = actSaveAs
      end
      object Close1: TMenuItem
        Action = actClose
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Extension1: TMenuItem
        Action = actRegisterExtension
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = actExit
      end
    end
  end
  object alMain: TActionList
    Left = 80
    Top = 64
    object actOpen: TAction
      Category = 'File'
      Caption = 'Open...'
      ShortCut = 16463
      OnExecute = actOpenExecute
    end
    object actSave: TAction
      Category = 'File'
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = actSaveExecute
      OnUpdate = actSaveUpdate
    end
    object actSaveAs: TAction
      Category = 'File'
      Caption = 'Save as...'
      ShortCut = 24659
      OnExecute = actSaveAsExecute
      OnUpdate = actSaveAsUpdate
    end
    object actExit: TAction
      Category = 'File'
      Caption = 'Exit'
      OnExecute = actExitExecute
    end
    object actNewMap: TAction
      Category = 'File'
      Caption = 'New Map'
      ShortCut = 16462
      OnExecute = actNewMapExecute
    end
    object actNewList: TAction
      Category = 'File'
      Caption = 'New List'
      ShortCut = 16461
      OnExecute = actNewListExecute
    end
    object actRegisterExtension: TAction
      Category = 'File'
      Caption = 'Register .ubs Extension'
      OnExecute = actRegisterExtensionExecute
      OnUpdate = actRegisterExtensionUpdate
    end
    object actClose: TAction
      Category = 'File'
      Caption = 'Close'
      SecondaryShortCuts.Strings = (
        'Ctrl+F4')
      ShortCut = 16471
      OnExecute = actCloseExecute
      OnUpdate = actCloseUpdate
    end
  end
  object aeEvents: TApplicationEvents
    OnActivate = aeEventsActivate
    Left = 128
    Top = 64
  end
end
