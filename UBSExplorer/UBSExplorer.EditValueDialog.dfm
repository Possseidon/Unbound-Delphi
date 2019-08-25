object dlgEditValue: TdlgEditValue
  Left = 195
  Top = 108
  BorderStyle = bsSizeToolWin
  Caption = 'Edit Value'
  ClientHeight = 192
  ClientWidth = 279
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 279
    Height = 158
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    ParentColor = True
    TabOrder = 0
    object pcValueTypes: TPageControl
      Left = 5
      Top = 5
      Width = 269
      Height = 148
      ActivePage = TabSheet4
      Align = alClient
      Images = dmData.ilIcons
      MultiLine = True
      TabOrder = 0
      TabWidth = 22
      object TabSheet1: TTabSheet
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
      object TabSheet2: TTabSheet
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
      object TabSheet3: TTabSheet
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
      object TabSheet4: TTabSheet
        ImageIndex = 3
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 158
    Width = 279
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    DesignSize = (
      279
      34)
    object OKBtn: TButton
      Left = 115
      Top = 1
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object CancelBtn: TButton
      Left = 195
      Top = 1
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
