unit Unbound.Game.Serialization;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Math,

  Pengine.Utility,
  Pengine.ICollections,
  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.Color,
  Pengine.Formatting;

type

  TBinaryWriterHelper = class helper for TBinaryWriter
    procedure Write7BitEncodedInt(Value: Integer);

  end;

  TBinaryReaderHelper = class helper for TBinaryReader
    function Read7BitEncodedInt: Integer;

  end;

  EUBSError = class(Exception);

  TUBSTag = (
    // Nil type
    utNil,

    // Basic/Nested structures
    utMap,
    utList,

    // Common Primitives
    utInteger,
    utSingle,
    utBoolean,
    utString,
    utByteArray,

    // Utility
    utGUID,

    // Integer math
    utIntBounds1,
    utIntBounds2,
    utIntBounds3,
    utIntVector2,
    utIntVector3,

    // Vector math
    utBounds1,
    utBounds2,
    utBounds3,
    utVector2,
    utVector3,

    // Color
    utColorRGB,
    utColorRGBA
    );

  TUBSClass = class of TUBSValue;

  TUBSValue = class
  public const

    BinaryFileSignature: array [0 .. 3] of Byte = (27, Ord('U'), Ord('B'), Ord('S'));

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

    procedure SaveInternal(AWriter: TBinaryWriter); virtual; abstract;
    procedure LoadInternal(AReader: TBinaryReader); virtual; abstract;

  public
    constructor Create; virtual;

    class function GetTag: TUBSTag; virtual; abstract;
    class function GetTagName: string;

    procedure Save(AWriter: TBinaryWriter);
    class function Load(AReader: TBinaryReader): TUBSValue; static;

    procedure SaveToFile(const AFilename: string);
    class function LoadFromFile(const AFilename: string): TUBSValue; static;

    function Cast<T: TUBSValue>: T;

    function Formatter: IFormatter;
    function Format(AMode: TUBSFormatMode = TFormatter.DefaultMode): string;
    function ToString: string; override;

  end;

  TUBSNil = class(TUBSValue)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

    procedure SaveInternal(AWriter: TBinaryWriter); override;
    procedure LoadInternal(AReader: TBinaryReader); override;

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
    function GetCount: Integer;

  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

    procedure SaveInternal(AWriter: TBinaryWriter); override;
    procedure LoadInternal(AReader: TBinaryReader); override;

  public
    constructor Create; override;

    class function GetTag: TUBSTag; override;

    property Count: Integer read GetCount;
    property Map: IReadonlyMap<string, TUBSValue> read GetMap;
    property Order: IReadonlyList < TPair < string, TUBSValue >> read GetOrder;

    property Items[AKey: string]: TUBSValue read GetItem write SetItem; default;

  end;

  TUBSList = class(TUBSValue)
  private
    FItems: IObjectList<TUBSValue>;

    function GetItem(AIndex: Integer): TUBSValue;
    procedure SetItem(AIndex: Integer; const Value: TUBSValue);
    function GetItems: IReadonlyList<TUBSValue>;
    function GetCount: Integer;

  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

    procedure SaveInternal(AWriter: TBinaryWriter); override;
    procedure LoadInternal(AReader: TBinaryReader); override;

  public
    constructor Create; override;

    class function GetTag: TUBSTag; override;

    property Count: Integer read GetCount;
    property Items: IReadonlyList<TUBSValue> read GetItems;
    property Values[AIndex: Integer]: TUBSValue read GetItem write SetItem; default;
    procedure Add(AValue: TUBSValue);

    function GetEnumerator: IIterator<TUBSValue>;

  end;

  TUBSValue<T> = class(TUBSValue)
  private
    FValue: T;

  protected
    procedure SaveInternal(AWriter: TBinaryWriter); override;
    procedure LoadInternal(AReader: TBinaryReader); override;

  public
    constructor Create; overload; override;
    constructor Create(AValue: T); reintroduce; overload;

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
  public const

    BoolStrings: array [Boolean] of string = ('false', 'true');

  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSString = class(TUBSValue<string>)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

    procedure SaveInternal(AWriter: TBinaryWriter); override;
    procedure LoadInternal(AReader: TBinaryReader); override;

  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSByteArray = class(TUBSValue)
  protected
    procedure FormatInternal(AFormatter: TUBSValue.TFormatter); override;

    procedure SaveInternal(AWriter: TBinaryWriter); override;
    procedure LoadInternal(AReader: TBinaryReader); override;

  public
    Data: TBytes;

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

    procedure Define(const AName: string; var AValue: TGUID); overload;
    procedure Define(const AName: string; const ACollection: ICollection<TGUID>); overload;

    procedure Define(const AName: string; var AValue: TIntBounds1); overload;
    procedure Define(const AName: string; var AValue: TIntBounds2); overload;
    procedure Define(const AName: string; var AValue: TIntBounds3); overload;
    procedure Define(const AName: string; var AValue: TIntVector2); overload;
    procedure Define(const AName: string; var AValue: TIntVector3); overload;

    procedure Define(const AName: string; var AValue: TBounds1); overload;
    procedure Define(const AName: string; var AValue: TBounds2); overload;
    procedure Define(const AName: string; var AValue: TBounds3); overload;
    procedure Define(const AName: string; var AValue: TVector2); overload;
    procedure Define(const AName: string; var AValue: TVector3); overload;

    procedure Define(const AName: string; var AValue: TColorRGB); overload;
    procedure Define(const AName: string; var AValue: TColorRGBA); overload;

    procedure WriteOnly(const AName: string; const AValue: Integer); overload;
    procedure WriteOnly(const AName: string; const AValue: Single); overload;
    procedure WriteOnly(const AName: string; const AValue: Boolean); overload;
    procedure WriteOnly(const AName: string; const AValue: string); overload;

    procedure WriteOnly(const AName: string; const AValue: TGUID); overload;

    procedure WriteOnly(const AName: string; const AValue: TIntBounds1); overload;
    procedure WriteOnly(const AName: string; const AValue: TIntBounds2); overload;
    procedure WriteOnly(const AName: string; const AValue: TIntBounds3); overload;
    procedure WriteOnly(const AName: string; const AValue: TIntVector2); overload;
    procedure WriteOnly(const AName: string; const AValue: TIntVector3); overload;

    procedure WriteOnly(const AName: string; const AValue: TBounds1); overload;
    procedure WriteOnly(const AName: string; const AValue: TBounds2); overload;
    procedure WriteOnly(const AName: string; const AValue: TBounds3); overload;
    procedure WriteOnly(const AName: string; const AValue: TVector2); overload;
    procedure WriteOnly(const AName: string; const AValue: TVector3); overload;

    procedure WriteOnly(const AName: string; const AValue: TColorRGB); overload;
    procedure WriteOnly(const AName: string; const AValue: TColorRGBA); overload;

  end;

  ISerializable = interface
    procedure Serialize(ASerializer: TSerializer);

  end;

const

  UBSClasses: array [TUBSTag] of TUBSClass = (
    // Nil type
    TUBSNil,

    // Basic/Nested structures
    TUBSMap,
    TUBSList,

    // Common Primitives
    TUBSInteger,
    TUBSSingle,
    TUBSBoolean,
    TUBSString,
    TUBSByteArray,

    // Utility
    TUBSGUID,

    // Integer math
    TUBSIntBounds1,
    TUBSIntBounds2,
    TUBSIntBounds3,
    TUBSIntVector2,
    TUBSIntVector3,

    // Vector math
    TUBSBounds1,
    TUBSBounds2,
    TUBSBounds3,
    TUBSVector2,
    TUBSVector3,

    // Color
    TUBSColorRGB,
    TUBSColorRGBA
    );

  UBSTagNames: array [TUBSTag] of string = (
    // Nil type
    'nil',

    // Basic/Nested structures
    'map',
    'list',

    // Common Primitives
    'integer',
    'single',
    'boolean',
    'string',
    'bytes',

    // Utility
    'guid',

    // Integer math
    'ibounds1',
    'ibounds2',
    'ibounds3',
    'ivec2',
    'ivec3',

    // Vector math
    'bound1',
    'bound2',
    'bound3',
    'vec2',
    'vec3',

    // Color
    'rgb',
    'rgba'
    );

implementation

{ TBinaryWriterHelper }

procedure TBinaryWriterHelper.Write7BitEncodedInt(Value: Integer);
begin
  inherited Write7BitEncodedInt(Value);
end;

{ TBinaryReaderHelper }

function TBinaryReaderHelper.Read7BitEncodedInt: Integer;
begin
  Result := inherited Read7BitEncodedInt;
end;

{ TUBSNil }

procedure TUBSNil.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('nil');
end;

class function TUBSNil.GetTag: TUBSTag;
begin
  Result := utNil;
end;

procedure TUBSNil.LoadInternal(AReader: TBinaryReader);
begin
  // nothing
end;

procedure TUBSNil.SaveInternal(AWriter: TBinaryWriter);
begin
  // nothing
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

function TUBSMap.GetCount: Integer;
begin
  Result := Map.Count;
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
      if AFormatter.Mode = ufInline then
        AFormatter.Builder.Append(' ');
      AFormatter.NewLine;
      FormatIndex(I);
    end;
    AFormatter.Unindent;
  end;
  AFormatter.Builder.Append('}');
end;

procedure TUBSMap.SaveInternal(AWriter: TBinaryWriter);
var
  Item: TPair<string, TUBSValue>;
begin
  AWriter.Write7BitEncodedInt(Count);
  for Item in Order do
  begin
    AWriter.Write(Item.Key);
    Item.Value.Save(AWriter);
  end;
end;

procedure TUBSMap.LoadInternal(AReader: TBinaryReader);
var
  I: Integer;
  Key: string;
  Value: TUBSValue;
begin
  for I := 1 to AReader.Read7BitEncodedInt do
  begin
    Key := AReader.ReadString;
    Value := Load(AReader);
    Items[Key] := Value;
  end;
end;

constructor TUBSMap.Create;
begin
  FMap := TToObjectMap<string, TUBSValue>.Create;
  FOrder := TList < TPair < string, TUBSValue >>.Create;
end;

class function TUBSMap.GetTag: TUBSTag;
begin
  Result := utMap;
end;

{ IUBSList }

function TUBSList.GetItem(AIndex: Integer): TUBSValue;
begin
  Result := FItems[AIndex];
end;

procedure TUBSList.SetItem(AIndex: Integer; const Value: TUBSValue);
begin
  FItems[AIndex] := Value;
end;

function TUBSList.GetItems: IReadonlyList<TUBSValue>;
begin
  Result := FItems.ReadonlyList;
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
      if AFormatter.Mode = ufInline then
        AFormatter.Builder.Append(' ');
      AFormatter.NewLine;
      Items[I].FormatInternal(AFormatter);
    end;
    AFormatter.Unindent;
  end;
  AFormatter.Builder.Append(']');
end;

procedure TUBSList.SaveInternal(AWriter: TBinaryWriter);
var
  Item: TUBSValue;
begin
  AWriter.Write7BitEncodedInt(Count);
  for Item in Items do
    Item.Save(AWriter);
end;

procedure TUBSList.LoadInternal(AReader: TBinaryReader);
var
  I: Integer;
begin
  for I := 1 to AReader.Read7BitEncodedInt do
    Add(Load(AReader));
end;

constructor TUBSList.Create;
begin
  FItems := TObjectList<TUBSValue>.Create;
end;

class function TUBSList.GetTag: TUBSTag;
begin
  Result := utList;
end;

procedure TUBSList.Add(AValue: TUBSValue);
begin
  FItems.Add(AValue);
end;

function TUBSList.GetCount: Integer;
begin
  Result := Items.Count;
end;

function TUBSList.GetEnumerator: IIterator<TUBSValue>;
begin
  Result := FItems.GetEnumerator;
end;

{ TUBSInteger }

procedure TUBSInteger.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append(Value);
end;

class function TUBSInteger.GetTag: TUBSTag;
begin
  Result := utInteger;
end;

{ TUBSSingle }

procedure TUBSSingle.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append(PrettyFloat(Value));
  if not IsInfinite(Value) and not IsNan(Value) then
    AFormatter.Builder.Append('f');
end;

class function TUBSSingle.GetTag: TUBSTag;
begin
  Result := utSingle;
end;

{ TUBSBoolean }

procedure TUBSBoolean.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append(BoolStrings[Value]);
end;

class function TUBSBoolean.GetTag: TUBSTag;
begin
  Result := utBoolean;
end;

{ TUBSString }

procedure TUBSString.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append(Value.QuotedString('"'));
end;

procedure TUBSString.SaveInternal(AWriter: TBinaryWriter);
begin
  AWriter.Write(Value);
end;

procedure TUBSString.LoadInternal(AReader: TBinaryReader);
begin
  Value := AReader.ReadString;
end;

class function TUBSString.GetTag: TUBSTag;
begin
  Result := utString;
end;

{ TUBSByteArray }

procedure TUBSByteArray.FormatInternal(AFormatter: TUBSValue.TFormatter);
var
  I: Integer;
begin
  AFormatter.Builder.Append('bytes(');
  for I := 0 to Length(Data) - 1 do
    AFormatter.Builder.Append(IntToHex(Data[I]));
  AFormatter.Builder.Append(')');
end;

procedure TUBSByteArray.SaveInternal(AWriter: TBinaryWriter);
begin
  AWriter.Write7BitEncodedInt(Length(Data));
  AWriter.Write(Data);
end;

procedure TUBSByteArray.LoadInternal(AReader: TBinaryReader);
var
  Count: Integer;
begin
  Count := AReader.Read7BitEncodedInt;
  SetLength(Data, Count);
  AReader.Read(Data, 0, Count);
end;

class function TUBSByteArray.GetTag: TUBSTag;
begin
  Result := utByteArray;
end;

{ TUBSGUID }

procedure TUBSGUID.FormatInternal(AFormatter: TUBSValue.TFormatter);
var
  Text: string;
begin
  Text := Value.ToString;
  Text[1] := '<';
  Text[38] := '>';
  AFormatter.Builder.Append(Text);
end;

class function TUBSGUID.GetTag: TUBSTag;
begin
  Result := utGUID;
end;

{ TUBSIntBounds1 }

procedure TUBSIntBounds1.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('ibounds1(');
  AFormatter.Builder.Append(Value.C1);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C2);
  AFormatter.Builder.Append(')');
end;

class function TUBSIntBounds1.GetTag: TUBSTag;
begin
  Result := utIntBounds1;
end;

{ TUBSIntBounds2 }

procedure TUBSIntBounds2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('ibounds2(');
  AFormatter.Builder.Append(Value.C1.X);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C1.Y);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C2.X);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C2.Y);
  AFormatter.Builder.Append(')');
end;

class function TUBSIntBounds2.GetTag: TUBSTag;
begin
  Result := utIntBounds2;
end;

{ TUBSIntBounds3 }

procedure TUBSIntBounds3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('ibounds3(');
  AFormatter.Builder.Append(Value.C1.X);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C1.Y);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C1.Z);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C2.X);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C2.Y);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.C2.Z);
  AFormatter.Builder.Append(')');
end;

class function TUBSIntBounds3.GetTag: TUBSTag;
begin
  Result := utIntBounds3;
end;

{ TUBSIntVector2 }

procedure TUBSIntVector2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('ivec2(');
  AFormatter.Builder.Append(Value.X);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.Y);
  AFormatter.Builder.Append(')');
end;

class function TUBSIntVector2.GetTag: TUBSTag;
begin
  Result := utIntVector2;
end;

{ TUBSIntVector3 }

procedure TUBSIntVector3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('ivec3(');
  AFormatter.Builder.Append(Value.X);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.Y);
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(Value.Z);
  AFormatter.Builder.Append(')');
end;

class function TUBSIntVector3.GetTag: TUBSTag;
begin
  Result := utIntVector3;
end;

{ TUBSBounds1 }

procedure TUBSBounds1.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('bounds1(');
  AFormatter.Builder.Append(PrettyFloat(Value.C1));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C2));
  AFormatter.Builder.Append(')');
end;

class function TUBSBounds1.GetTag: TUBSTag;
begin
  Result := utBounds1;
end;

{ TUBSBounds2 }

procedure TUBSBounds2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('bounds2(');
  AFormatter.Builder.Append(PrettyFloat(Value.C1.X));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C1.Y));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C2.X));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C2.Y));
  AFormatter.Builder.Append(')');
end;

class function TUBSBounds2.GetTag: TUBSTag;
begin
  Result := utBounds2;
end;

{ TUBSBounds3 }

procedure TUBSBounds3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('bounds3(');
  AFormatter.Builder.Append(PrettyFloat(Value.C1.X));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C1.Y));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C1.Z));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C2.X));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C2.Y));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.C2.Z));
  AFormatter.Builder.Append(')');
end;

class function TUBSBounds3.GetTag: TUBSTag;
begin
  Result := utBounds3;
end;

{ TUBSVector2 }

procedure TUBSVector2.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('vec2(');
  AFormatter.Builder.Append(PrettyFloat(Value.X));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.Y));
  AFormatter.Builder.Append(')');
end;

class function TUBSVector2.GetTag: TUBSTag;
begin
  Result := utVector2;
end;

{ TUBSVector3 }

procedure TUBSVector3.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('vec3(');
  AFormatter.Builder.Append(PrettyFloat(Value.X));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.Y));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.Z));
  AFormatter.Builder.Append(')');
end;

class function TUBSVector3.GetTag: TUBSTag;
begin
  Result := utVector3;
end;

{ TUBSColorRGB }

procedure TUBSColorRGB.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('rgb(');
  AFormatter.Builder.Append(PrettyFloat(Value.R));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.G));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.B));
  AFormatter.Builder.Append(')');
end;

class function TUBSColorRGB.GetTag: TUBSTag;
begin
  Result := utColorRGB;
end;

{ TUBSColorRGBA }

procedure TUBSColorRGBA.FormatInternal(AFormatter: TUBSValue.TFormatter);
begin
  AFormatter.Builder.Append('rgba(');
  AFormatter.Builder.Append(PrettyFloat(Value.R));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.G));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.B));
  AFormatter.Builder.Append(',');
  if AFormatter.Mode <> ufMinify then
    AFormatter.Builder.Append(' ');
  AFormatter.Builder.Append(PrettyFloat(Value.A));
  AFormatter.Builder.Append(')');
end;

class function TUBSColorRGBA.GetTag: TUBSTag;
begin
  Result := utColorRGBA;
end;

{ TSerializer }

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

procedure TSerializer.Define(const AName: string; const ASerializable: ISerializable);
begin
  case Mode of
    smSerialize:
      Value[AName] := Serialize(ASerializable);
    smUnserialize:
      Unserialize(ASerializable, Value[AName].Cast<TUBSMap>);
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

procedure TSerializer.Define<T>(const AName: string; var ASerializable: T; const AInstantiator: TFunc<TUBSMap, T>);
var
  utMap: TUBSMap;
begin
  case Mode of
    smSerialize:
      Value[AName] := Serialize(ASerializable);
    smUnserialize:
      begin
        utMap := Value[AName].Cast<TUBSMap>;
        ASerializable := AInstantiator(utMap);
        Unserialize(ASerializable, utMap);
      end;
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

procedure TSerializer.Define<T>(const AName: string; const ACollection: ICollection<T>;
  const AInstantiator: TFunc<TUBSMap, T>);
var
  List: TUBSList;
  Item: T;
  UBSValue: TUBSValue;
  utMap: TUBSMap;
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
          utMap := UBSValue.Cast<TUBSMap>;
          Item := AInstantiator(utMap);
          Unserialize(Item, utMap);
          ACollection.Add(Item);
        end;
      end;
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

procedure TSerializer.Define(const AName: string; var AValue: Boolean);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSBoolean.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSBoolean>.Value;
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

procedure TSerializer.Define(const AName: string; var AValue: TGUID);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSGUID.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSGUID>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TIntBounds1);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSIntBounds1.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSIntBounds1>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TIntBounds2);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSIntBounds2.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSIntBounds2>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TIntBounds3);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSIntBounds3.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSIntBounds3>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TIntVector2);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSIntVector2.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSIntVector2>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TIntVector3);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSIntVector3.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSIntVector3>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TBounds1);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSBounds1.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSBounds1>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TBounds2);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSBounds2.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSBounds2>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TBounds3);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSBounds3.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSBounds3>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TVector2);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSVector2.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSVector2>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TVector3);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSVector3.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSVector3>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TColorRGB);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSColorRGB.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSColorRGB>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; var AValue: TColorRGBA);
begin
  case Mode of
    smSerialize:
      Value[AName] := TUBSColorRGBA.Create(AValue);
    smUnserialize:
      AValue := Value[AName].Cast<TUBSColorRGBA>.Value;
  end;
end;

procedure TSerializer.Define(const AName: string; ACollection: ICollection<TGUID>);
var
  List: TUBSList;
  GUID: TGUID;
  UBSValue: TUBSValue;
begin
  case Mode of
    smSerialize:
      begin
        List := TUBSList.Create;
        for GUID in ACollection do
          List.Add(TUBSGUID.Create(GUID));
        Value[AName] := List;
      end;
    smUnserialize:
      begin
        ACollection.Clear;
        for UBSValue in Value[AName].Cast<TUBSList> do
          ACollection.Add(UBSValue.Cast<TUBSGUID>.Value);
      end;
  end;
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: Integer);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSInteger.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: Single);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSSingle.Create(AValue);
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

procedure TSerializer.WriteOnly(const AName: string; const AValue: TGUID);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSGUID.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TIntBounds1);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSIntBounds1.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TIntBounds2);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSIntBounds2.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TIntBounds3);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSIntBounds3.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TIntVector2);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSIntVector2.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TIntVector3);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSIntVector3.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TBounds1);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSBounds1.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TBounds2);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSBounds2.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TBounds3);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSBounds3.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TVector2);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSVector2.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TVector3);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSVector3.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TColorRGB);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSColorRGB.Create(AValue);
end;

procedure TSerializer.WriteOnly(const AName: string; const AValue: TColorRGBA);
begin
  if Mode = smSerialize then
    Value[AName] := TUBSColorRGBA.Create(AValue);
end;

{ TUBSValue }

procedure TUBSValue.Save(AWriter: TBinaryWriter);
begin
  AWriter.Write7BitEncodedInt(Ord(GetTag));
  SaveInternal(AWriter);
end;

class function TUBSValue.Load(AReader: TBinaryReader): TUBSValue;
var
  Tag: TUBSTag;
begin
  Tag := TUBSTag(AReader.Read7BitEncodedInt);
  if not(Tag in [Low(TUBSTag) .. High(TUBSTag)]) then
    raise EUBSError.Create('Unknown UBS-Tag, newer version or corrupted data.');
  Result := UBSClasses[Tag].Create;
  Result.LoadInternal(AReader);
end;

constructor TUBSValue.Create;
begin
  // nothing
end;

procedure TUBSValue.SaveToFile(const AFilename: string);
var
  Writer: TBinaryWriter;
begin
  Writer := TBinaryWriter.Create(AFilename, False, TEncoding.UTF8);
  try
    Writer.Write(Cardinal(BinaryFileSignature));
    Save(Writer);
  finally
    Writer.Free;
  end;
end;

class function TUBSValue.LoadFromFile(const AFilename: string): TUBSValue;
var
  Reader: TBinaryReader;
begin
  Reader := TBinaryReader.Create(AFilename, TEncoding.UTF8);
  try
    try
      if Reader.ReadCardinal <> Cardinal(BinaryFileSignature) then
        raise EUBSError.Create('Loading non-binary UBS file not supported.');
      Result := Load(Reader);
    except
      raise EUBSError.Create('Invalid UBS file.');
    end;
  finally
    Reader.Free;
  end;
end;

function TUBSValue.Cast<T>: T;
begin
  if Self.ClassType = T then
    Exit(T(Self));
  raise EUBSError.Create('Invalid cast of UBS-Type.');
end;

function TUBSValue.Formatter: IFormatter;
begin
  Result := TFormatter.Create(Self);
end;

class function TUBSValue.GetTagName: string;
begin
  Result := UBSTagNames[GetTag];
end;

function TUBSValue.Format(AMode: TUBSFormatMode): string;
begin
  with Formatter do
  begin
    Mode := AMode;
    Result := Format;
  end;
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

procedure TUBSValue<T>.SaveInternal(AWriter: TBinaryWriter);
begin
  AWriter.BaseStream.Write(Value, SizeOf(T));
end;

procedure TUBSValue<T>.LoadInternal(AReader: TBinaryReader);
begin
  AReader.BaseStream.ReadData<T>(FValue);
end;

constructor TUBSValue<T>.Create;
begin
  inherited;
end;

constructor TUBSValue<T>.Create(AValue: T);
begin
  Create;
  FValue := AValue;
end;

end.
