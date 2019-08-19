unit Unbound.Game.Serialization;

interface

uses
  System.SysUtils,

  Pengine.ICollections,
  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.Color,
  Pengine.Formatting;

type

  EUBSError = class(Exception);

  TUBSTag = (
    // Nil type
    ubsNil,

    // Basic/Nested structures
    ubsMap,
    ubsList,

    // Common Primitives
    ubsInteger,
    ubsSingle,
    ubsBoolean,
    ubsString,
    ubsByteArray,

    // Utility
    ubsGUID,

    // Integer math
    ubsIntBounds1,
    ubsIntBounds2,
    ubsIntBounds3,
    ubsIntVector2,
    ubsIntVector3,

    // Vector math
    ubsBounds1,
    ubsBounds2,
    ubsBounds3,
    ubsVector2,
    ubsVector3,

    // Color
    ubsColorRGB,
    ubsColorRGBA
    );

  TUBSValue = class
  public type

    TUBSFormatMode = (
      ufPretty,
      ufInline,
      ufMinify
      );

    IFormatter = interface(IFormatter<TUBSValue>)
      function GetMode: TUBSFormatMode;
      procedure SetMode(const Value: TUBSFormatMode);
      function GetIndentWidth: Integer;
      procedure SetIndentWidth(const Value: Integer);

      property Mode: TUBSFormatMode read GetMode write SetMode;
      property IndentWidth: Integer read GetIndentWidth write SetIndentWidth;

    end;

    TFormatter = class(TFormatter<TUBSValue>, IFormatter)
    public const

      DefaultMode = ufPretty;
      DefaultIndentWidth = 2;

    private
      FBuilder: TStringBuilder;
      FIndentLevel: Integer;

      // Format-Settings
      FMode: TUBSFormatMode;
      FIndentWidth: Integer;

      function GetMode: TUBSFormatMode;
      procedure SetMode(const Value: TUBSFormatMode);
      function GetIndentWidth: Integer;
      procedure SetIndentWidth(const Value: Integer);

    public
      constructor Create; override;

      function Format: string; override;

      property Mode: TUBSFormatMode read GetMode write SetMode;
      property IndentWidth: Integer read GetIndentWidth write SetIndentWidth;

      property Builder: TStringBuilder read FBuilder;
      procedure Indent; inline;
      procedure Unindent; inline;
      procedure AddIndentation; inline;
      procedure NewLine; inline;
      property IndentLevel: Integer read FIndentLevel;

    end;

  protected
    procedure FormatInternal(AFormatter: TFormatter); virtual; abstract;

  public
    class function GetTag: TUBSTag; virtual; abstract;

    function Cast<T: TUBSValue>: T;

    function Formatter: IFormatter;
    function Format(AMode: TUBSFormatMode = TFormatter.DefaultMode): string;
    function ToString: string; override;

  end;

  TUBSNil = class(TUBSValue)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSMap = class(TUBSValue)
  private
    FMap: IToObjectMap<string, TUBSValue>;
    FOrder: IList<TPair<string, TUBSValue>>;

    function GetMap: IReadonlyMap<string, TUBSValue>;
    function GetOrder: IReadonlyList<TPair<string, TUBSValue>>;

    function GetItem(AKey: string): TUBSValue;
    procedure SetItem(AKey: string; const Value: TUBSValue);

  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    constructor Create;

    class function GetTag: TUBSTag; override;

    property Map: IReadonlyMap<string, TUBSValue> read GetMap;
    property Order: IReadonlyList<TPair<string, TUBSValue>> read GetOrder;

    property Items[AKey: string]: TUBSValue read GetItem write SetItem; default;

  end;

  TUBSList = class(TUBSValue)
  private
    FItems: IObjectList<TUBSValue>;

    function GetItem(AIndex: Integer): TUBSValue;
    procedure SetItem(AIndex: Integer; const Value: TUBSValue);
    function GetItems: IReadonlyList<TUBSValue>;

  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    constructor Create;

    class function GetTag: TUBSTag; override;

    property Items: IReadonlyList<TUBSValue> read GetItems;
    property Values[AIndex: Integer]: TUBSValue read GetItem write SetItem; default;
    procedure Add(AValue: TUBSValue);

    function GetEnumerator: IIterator<TUBSValue>;

  end;

  TUBSValue<T> = class(TUBSValue)
  private
    FValue: T;

  public
    constructor Create(AValue: T);

    property Value: T read FValue write FValue;

  end;

  TUBSInteger = class(TUBSValue<Integer>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSSingle = class(TUBSValue<Single>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBoolean = class(TUBSValue<Boolean>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSString = class(TUBSValue<string>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSByteArray = class(TUBSValue)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSGUID = class(TUBSValue<TGUID>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntBounds1 = class(TUBSValue<TIntBounds1>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntBounds2 = class(TUBSValue<TIntBounds2>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntBounds3 = class(TUBSValue<TIntBounds3>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntVector2 = class(TUBSValue<TIntVector2>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntVector3 = class(TUBSValue<TIntVector3>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBounds1 = class(TUBSValue<TBounds1>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBounds2 = class(TUBSValue<TBounds2>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBounds3 = class(TUBSValue<TBounds3>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSVector2 = class(TUBSValue<TVector2>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSVector3 = class(TUBSValue<TVector3>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSColorRGB = class(TUBSValue<TColorRGB>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSColorRGBA = class(TUBSValue<TColorRGBA>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  ISerializable = interface;

  TSerializer = class
  public type

    TMode = (
      smSerialize,
      smUnserialize
      );

  private
    FMode: TMode;
    FValue: TUBSMap;

  public
    class function Serialize(ASerializable: ISerializable): TUBSMap;
    class procedure Unserialize(ASerializable: ISerializable; AValue: TUBSMap);

    property Mode: TMode read FMode;
    property Value: TUBSMap read FValue;

    procedure Define(const AName: string; const ASerializable: ISerializable); overload;
    procedure Define<T: ISerializable>(const AName: string; var ASerializable: T;
      const AInstantiator: TFunc<T>); overload;
    procedure Define<T: ISerializable>(const AName: string; var ASerializable: T;
      const AInstantiator: TFunc<TUBSMap, T>); overload;

    procedure Define<T: ISerializable>(const AName: string; const ACollection: ICollection<T>;
      const AInstantiator: TFunc<T>); overload;
    procedure Define<T: ISerializable>(const AName: string; const ACollection: ICollection<T>;
      const AInstantiator: TFunc<TUBSMap, T>); overload;
    procedure Define<T: ISerializable, constructor>(const AName: string; const ACollection: ICollection<T>); overload;

    procedure Define(const AName: string; var AValue: Integer); overload;
    procedure Define(const AName: string; var AValue: Single); overload;
    procedure Define(const AName: string; var AValue: Boolean); overload;
    procedure Define(const AName: string; var AValue: string); overload;

    procedure WriteOnly(const AName: string; const AValue: Integer); overload;
    procedure WriteOnly(const AName: string; const AValue: Single); overload;
    procedure WriteOnly(const AName: string; const AValue: Boolean); overload;
    procedure WriteOnly(const AName: string; const AValue: string); overload;

  end;

  ISerializable = interface
    procedure Serialize(ASerializer: TSerializer);

  end;

implementation

{ TUBSNil }

procedure TUBSNil.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('nil');
end;

class function TUBSNil.GetTag: TUBSTag;
begin
  Result := ubsNil;
end;

{ TUBSMap }

function TUBSMap.GetMap: IReadonlyMap<string, TUBSValue>;
begin
  Result := FMap.ReadonlyMap;
end;

function TUBSMap.GetOrder: IReadonlyList<TPair<string, TUBSValue>>;
begin
  Result := FOrder.ReadonlyList;
end;

procedure TUBSMap.FormatInternal(AFormatter: TUBSValue.TFormatter);

  procedure FormatIndex(AIndex: Integer);
  begin
    AFormatter.Builder.Append(Order[AIndex].Key);
    AFormatter.Builder.Append(':');
    if AFormatter.Mode <> ufMinify then
      AFormatter.Builder.Append(' ');
    Order[AIndex].Value.FormatInternal(AFormatter);
  end;

var
  I: Integer;
begin
  AFormatter.Builder.Append('{');
  if not Map.Empty then
  begin
    AFormatter.Indent;
    FormatIndex(0);
    for I := 1 to Order.MaxIndex do
    begin
      AFormatter.Builder.Append(',');
      if AFormatter.Mode <> ufMinify then
        AFormatter.Builder.Append(' ');
      AFormatter.NewLine;
      FormatIndex(I);
    end;
    AFormatter.Unindent;
  end;
  AFormatter.Builder.Append('}');
end;

function TUBSMap.GetItem(AKey: string): TUBSValue;
begin
  Result := FMap[AKey];
end;

procedure TUBSMap.SetItem(AKey: string; const Value: TUBSValue);
begin
  if FMap.ContainsKey(AKey) then
    raise EUBSError.Create('UBS-Key exists already.');
  FMap[AKey] := Value;
  FOrder.Add(TPair<string, TUBSValue>.Create(AKey, Value));
end;

constructor TUBSMap.Create;
begin
  FMap := TToObjectMap<string, TUBSValue>.Create;
  FOrder := TList<TPair<string, TUBSValue>>.Create;
end;

class function TUBSMap.GetTag: TUBSTag;
begin
  Result := ubsMap;
end;

{ IUBSList }

function TUBSList.GetItem(AIndex: Integer): TUBSValue;
begin
  Result := FItems[AIndex];
end;

function TUBSList.GetItems: IReadonlyList<TUBSValue>;
begin
  Result := FItems.ReadonlyList;
end;

procedure TUBSList.SetItem(AIndex: Integer; const Value: TUBSValue);
begin
  FItems[AIndex] := Value;
end;

constructor TUBSList.Create;
begin
  FItems := TObjectList<TUBSValue>.Create;
end;

procedure TUBSList.FormatInternal(AFormatter: TUBSValue.TFormatter);
var
  I: Integer;
begin
  AFormatter.Builder.Append('[');
  if not Items.Empty then
  begin
    AFormatter.Indent;
    Items.First.FormatInternal(AFormatter);
    for I := 1 to Items.MaxIndex do
    begin
      AFormatter.Builder.Append(',');
      if AFormatter.Mode <> ufMinify then
        AFormatter.Builder.Append(' ');
      AFormatter.NewLine;
      Items[I].FormatInternal(AFormatter);
    end;
    AFormatter.Unindent;
  end;
  AFormatter.Builder.Append(']');
end;

class function TUBSList.GetTag: TUBSTag;
begin
  Result := ubsList;
end;

procedure TUBSList.Add(AValue: TUBSValue);
begin
  FItems.Add(AValue);
end;

function TUBSList.GetEnumerator: IIterator<TUBSValue>;
begin
  Result := FItems.GetEnumerator;
end;

{ TUBSInteger }

procedure TUBSInteger.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSInteger.GetTag: TUBSTag;
begin
  Result := ubsInteger;
end;

{ TUBSSingle }

procedure TUBSSingle.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSSingle.GetTag: TUBSTag;
begin
  Result := ubsSingle;
end;

{ TUBSBoolean }

procedure TUBSBoolean.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSBoolean.GetTag: TUBSTag;
begin
  Result := ubsBoolean;
end;

{ TUBSString }

procedure TUBSString.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSString.GetTag: TUBSTag;
begin
  Result := ubsString;
end;

{ TUBSByteArray }

procedure TUBSByteArray.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSByteArray.GetTag: TUBSTag;
begin
  Result := ubsByteArray;
end;

{ TUBSGUID }

procedure TUBSGUID.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSGUID.GetTag: TUBSTag;
begin
  Result := ubsGUID;
end;

{ TUBSIntBounds1 }

procedure TUBSIntBounds1.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSIntBounds1.GetTag: TUBSTag;
begin
  Result := ubsIntBounds1;
end;

{ TUBSIntBounds2 }

procedure TUBSIntBounds2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSIntBounds2.GetTag: TUBSTag;
begin
  Result := ubsIntBounds2;
end;

{ TUBSIntBounds3 }

procedure TUBSIntBounds3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSIntBounds3.GetTag: TUBSTag;
begin
  Result := ubsIntBounds3;
end;

{ TUBSIntVector2 }

procedure TUBSIntVector2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSIntVector2.GetTag: TUBSTag;
begin
  Result := ubsIntVector2;
end;

{ TUBSIntVector3 }

procedure TUBSIntVector3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSIntVector3.GetTag: TUBSTag;
begin
  Result := ubsIntVector3;
end;

{ TUBSBounds1 }

procedure TUBSBounds1.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSBounds1.GetTag: TUBSTag;
begin
  Result := ubsBounds1;
end;

{ TUBSBounds2 }

procedure TUBSBounds2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSBounds2.GetTag: TUBSTag;
begin
  Result := ubsBounds2;
end;

{ TUBSBounds3 }

procedure TUBSBounds3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSBounds3.GetTag: TUBSTag;
begin
  Result := ubsBounds3;
end;

{ TUBSVector2 }

procedure TUBSVector2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSVector2.GetTag: TUBSTag;
begin
  Result := ubsVector2;
end;

{ TUBSVector3 }

procedure TUBSVector3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSVector3.GetTag: TUBSTag;
begin
  Result := ubsVector3;
end;

{ TUBSColorRGB }

procedure TUBSColorRGB.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSColorRGB.GetTag: TUBSTag;
begin
  Result := ubsColorRGB;
end;

{ TUBSColorRGBA }

procedure TUBSColorRGBA.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  raise ENotImplemented.Create('FormatInternal');
end;

class function TUBSColorRGBA.GetTag: TUBSTag;
begin
  Result := ubsColorRGBA;
end;

{ TSerializer }

procedure TSerializer.Define(const AName: string; const ASerializable: ISerializable);
begin
  case Mode of
    smSerialize:
      Value[AName] := Serialize(ASerializable);
    smUnserialize:
      Unserialize(ASerializable, Value[AName].Cast<TUBSMap>);
  end;
end;

procedure TSerializer.Define<T>(const AName: string; const ACollection: ICollection<T>; const AInstantiator: TFunc<T>);
var
  List: TUBSList;
  Item: T;
  UBSValue: TUBSValue;
begin
  case Mode of
    smSerialize:
      begin
        List := TUBSList.Create;
        for Item in ACollection do
          List.Add(Serialize(Item));
        Value[AName] := List;
      end;
    smUnserialize:
      begin
        ACollection.Clear;
        for UBSValue in Value[AName].Cast<TUBSList> do
        begin
          Item := AInstantiator;
          Unserialize(Item, UBSValue.Cast<TUBSMap>);
          ACollection.Add(Item);
        end;
      end;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: Integer);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSInteger.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSInteger>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: Single);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSSingle.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSSingle>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: string);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSString.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSString>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: Boolean);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSBoolean.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSBoolean>.Value;
  end;
end;

procedure TSerializer.Define<T>(const AName: string; const ACollection: ICollection<T>);
begin
  Define<T>(AName, ACollection,
    function: T
    begin
      Result := T.Create;
    end);
end;

procedure TSerializer.Define<T>(const AName: string; var ASerializable: T; const AInstantiator: TFunc<TUBSMap, T>);
var
  ubsMap: TUBSMap;
begin
  case Mode of
    smSerialize:
      Value[AName] := Serialize(ASerializable);
    smUnserialize:
      begin
        ubsMap := Value[AName].Cast<TUBSMap>;
        ASerializable := AInstantiator(ubsMap);
        Unserialize(ASerializable, ubsMap);
      end;
  end;
end;

procedure TSerializer.Define<T>(const AName: string; var ASerializable: T; const AInstantiator: TFunc<T>);
begin
  case Mode of
    smSerialize:
      Value[AName] := Serialize(ASerializable);
    smUnserialize:
      begin
        ASerializable := AInstantiator;
        Unserialize(ASerializable, Value[AName].Cast<TUBSMap>);
      end;
  end;
end;

procedure TSerializer.Define<T>(const AName: string; const ACollection: ICollection<T>;
const AInstantiator: TFunc<TUBSMap, T>);
var
  List: TUBSList;
  Item: T;
  UBSValue: TUBSValue;
  ubsMap: TUBSMap;
begin
  case Mode of
    smSerialize:
      begin
        List := TUBSList.Create;
        for Item in ACollection do
          List.Add(Serialize(Item));
        Value[AName] := List;
      end;
    smUnserialize:
      begin
        ACollection.Clear;
        for UBSValue in Value[AName].Cast<TUBSList> do
        begin
          ubsMap := UBSValue.Cast<TUBSMap>;
          Item := AInstantiator(ubsMap);
          Unserialize(Item, ubsMap);
          ACollection.Add(Item);
        end;
      end;
  end;
end;

class function TSerializer.Serialize(ASerializable: ISerializable): TUBSMap;
var
  Serializer: TSerializer;
begin
  Serializer := TSerializer.Create;
  Serializer.FMode := smSerialize;
  Serializer.FValue := TUBSMap.Create;
  try
    ASerializable.Serialize(Serializer);
    Result := Serializer.FValue;
  finally
    Serializer.Free;
  end;
end;

class procedure TSerializer.Unserialize(ASerializable: ISerializable; AValue: TUBSMap);
var
  Serializer: TSerializer;
begin
  Serializer := TSerializer.Create;
  Serializer.FMode := smUnserialize;
  Serializer.FValue := AValue;
  try
    ASerializable.Serialize(Serializer);
  finally
    Serializer.FValue.Free;
    Serializer.Free;
  end;
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: Single);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSSingle.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: Integer);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSInteger.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: Boolean);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSBoolean.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName, AValue: string);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSString.Create(AValue);
end;

{ TUBSValue }

function TUBSValue.Cast<T>: T;
begin
  if Self.ClassType = T then
    Exit(T(Self));
  raise EUBSError.Create('Invalid cast of UBS-Type.');
end;

function TUBSValue.Format(AMode: TUBSFormatMode): string;
begin
  with Formatter do
  begin
    Mode := AMode;
    Result := Format;
  end;
end;

function TUBSValue.Formatter: IFormatter;
begin
  Result := TFormatter.Create(Self);
end;

function TUBSValue.ToString: string;
begin
  Result := Format(ufInline);
end;

{ TUBSValue.TFormatter }

function TUBSValue.TFormatter.GetMode: TUBSFormatMode;
begin
  Result := FMode;
end;

procedure TUBSValue.TFormatter.SetMode(const Value: TUBSFormatMode);
begin
  FMode := Value;
end;

function TUBSValue.TFormatter.GetIndentWidth: Integer;
begin
  Result := FIndentWidth;
end;

procedure TUBSValue.TFormatter.SetIndentWidth(const Value: Integer);
begin
  FIndentWidth := Value;
end;

constructor TUBSValue.TFormatter.Create;
begin
  FMode := DefaultMode;
  FIndentWidth := DefaultIndentWidth;
end;

function TUBSValue.TFormatter.Format: string;
begin
  FBuilder := TStringBuilder.Create;
  try
    Value.FormatInternal(Self);
    Result := FBuilder.ToString;
  finally
    Builder.Free;
  end;
end;

procedure TUBSValue.TFormatter.Indent;
begin
  Inc(FIndentLevel);
  NewLine;
end;

procedure TUBSValue.TFormatter.Unindent;
begin
  Dec(FIndentLevel);
  NewLine;
end;

procedure TUBSValue.TFormatter.AddIndentation;
begin
  Builder.Append(' ', IndentLevel * IndentWidth);
end;

procedure TUBSValue.TFormatter.NewLine;
begin
  if Mode = ufPretty then
  begin
    Builder.AppendLine;
    AddIndentation;
  end;
end;

{ TUBSValue<T> }

constructor TUBSValue<T>.Create(AValue: T);
begin
  FValue := AValue;
end;

end.
