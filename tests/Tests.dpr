program Tests;

{$IFNDEF TESTINSIGHT}
  {$APPTYPE CONSOLE}
{$ENDIF}

{$STRONGLINKTYPES ON}

{$IF CompilerVersion <= 34.0}
{$DEFINE USE_ATTRIBUTE_HELPER}
{$ENDIF}


uses
  System.SysUtils,
  DUnitX.TestFramework,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  {$IFDEF USE_ATTRIBUTE_HELPER}
  AttributeHelper in '..\src\JSONMapper\AttributeHelper.pas',
  {$ENDIF }
  JSONMapper in '..\src\JSONMapper\JSONMapper.pas',
  JSONMapper.Exceptions in '..\src\JSONMapper\JSONMapper.Exceptions.pas',
  JSONMapper.Attributes in '..\src\JSONMapper\JSONMapper.Attributes.pas',
  JSONMapper.ClassFieldHelper in '..\src\JSONMapper\JSONMapper.ClassFieldHelper.pas',
  JSONMapper.EnumerableHelper in '..\src\JSONMapper\JSONMapper.EnumerableHelper.pas',
  JSONMapper.DateFormatter in '..\src\JSONMapper\JSONMapper.DateFormatter.pas',
  PublicFieldIterator in '..\src\JSONMapper\PublicFieldIterator.pas',
  ObjectToJSON._Object in 'ObjectToJSON\ObjectToJSON._Object.pas',
  ObjectToJSON.DateTime in 'ObjectToJSON\ObjectToJSON.DateTime.pas',
  ObjectToJSON.IgnoreAttribute in 'ObjectToJSON\ObjectToJSON.IgnoreAttribute.pas',
  ObjectToJSON.GenericList in 'ObjectToJSON\ObjectToJSON.GenericList.pas',
  ObjectToJSON._Record in 'ObjectToJSON\ObjectToJSON._Record.pas',
  ObjectToJSON.Arrays in 'ObjectToJSON\ObjectToJSON.Arrays.pas',
  ObjectToJSON.Variant in 'ObjectToJSON\ObjectToJSON.Variant.pas',
  JSONToObject._Object in 'JSONToObject\JSONToObject._Object.pas',
  JSONToObject._Record in 'JSONToObject\JSONToObject._Record.pas',
  JSONToObject.DateTime in 'JSONToObject\JSONToObject.DateTime.pas',
  JSONToObject.Variant in 'JSONToObject\JSONToObject.Variant.pas',
  ObjectMapper in '..\src\ObjectMapper\ObjectMapper.pas',
  QueryMapper in '..\src\QueryMapper\QueryMapper.pas',
  QueryMapper.Attributes in '..\src\QueryMapper\QueryMapper.Attributes.pas',
  QueryMapper.DatasetEnumerator in '..\src\QueryMapper\QueryMapper.DatasetEnumerator.pas',
  QueryMapper.RowMapper in '..\src\QueryMapper\QueryMapper.RowMapper.pas',
  QueryMapper.Exceptions in '..\src\QueryMapper\QueryMapper.Exceptions.pas',
  QueryMapper.Test in 'QueryMapper\QueryMapper.Test.pas',
  Nullable in '..\src\Nullable\Nullable.pas',
  Nullable.Test in 'Nullable\Nullable.Test.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
begin
  ReportMemoryLeaksOnShutdown := true;
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
