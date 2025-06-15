unit Http.Exceptions;

interface

uses
  System.SysUtils;

type
  EHttpException = class(Exception)
  public
    code: word;
    text: string;
    cause: string;
    constructor Create(code: word; msg: string); reintroduce; overload;
    constructor Create(code: word; msg: string; cause: string); reintroduce; overload;
  end;

  ENotFoundException = class(EHttpException)
  public
    constructor Create(text: string = ''); reintroduce; overload;
    constructor Create(text: string; cause: string); reintroduce; overload;
  end;

  EMethodNotAllowedException = class(EHttpException)
  public
    constructor Create(text: string = ''); reintroduce; overload;
    constructor Create(text: string; cause: string); reintroduce; overload;
  end;

  EUnsupportedMediaTypeException = class(EHttpException)
  public
    constructor Create(text: string = ''); reintroduce; overload;
    constructor Create(text: string; cause: string); reintroduce; overload;
  end;

  HttpErrors = record
  type
    NotFound = record
    const
      CODE = 404;
      TEXT = 'Not found';
    end;

    MethodNotAllowed = record
    const
      CODE = 405;
      TEXT = 'Method not allowed';
    end;

    UnsupportedMediaType = record
    const
      CODE = 415;
      TEXT = 'Unsupported Media Type';
    end;
  end;

implementation

{ EHttpException }

constructor EHttpException.Create(code: word; msg: string);
begin
  self.code := code;
  self.text := msg;
end;

constructor EHttpException.Create(code: word; msg, cause: string);
begin
  self.code := code;
  self.text := msg;
  self.cause := cause;
end;

{ ENotFoundException }

constructor ENotFoundException.Create(text: string);
begin
  self.code := HttpErrors.UnsupportedMediaType.CODE;
  self.text := text;

  if text.IsEmpty() then begin
    self.text := HttpErrors.UnsupportedMediaType.TEXT;
  end;
end;

constructor ENotFoundException.Create(text, cause: string);
begin
  Create(text);
  self.cause := cause;
end;

{ EMethodNotAllowedException }

constructor EMethodNotAllowedException.Create(text: string);
begin
  self.code := HttpErrors.MethodNotAllowed.CODE;
  self.text := text;

  if text.IsEmpty() then begin
    self.text := HttpErrors.MethodNotAllowed.TEXT;
  end;
end;

constructor EMethodNotAllowedException.Create(text, cause: string);
begin
  Create(text);
  self.cause := cause;
end;

{ EUnsupportedMediaTypeException }

constructor EUnsupportedMediaTypeException.Create(text: string);
begin
  self.code := HttpErrors.UnsupportedMediaType.CODE;
  self.text := text;

  if text.IsEmpty() then begin
    self.text := HttpErrors.UnsupportedMediaType.TEXT;
  end;
end;

constructor EUnsupportedMediaTypeException.Create(text: string; cause: string);
begin
  Create(text);
  self.cause := cause;
end;

end.
