unit ObjectMapper;

interface

type
  TObjectMapper<TDataClass: class, constructor; TDto: class, constructor> = class
  public
    procedure mapToDto(obj: TDataClass; dto: TDto); virtual; abstract;
    procedure mapFromDto(dto: TDto; obj: TDataClass); virtual; abstract;
  end;

implementation

end.
