program Tests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.TestFramework,
  JSONMapper in '..\src\JSONMapper\JSONMapper.pas',
  JSONMapper.Exceptions in '..\src\JSONMapper\JSONMapper.Exceptions.pas',
  JSONMapper.Attributes in '..\src\JSONMapper\JSONMapper.Attributes.pas',
  RttiUtils in '..\src\JSONMapper\RttiUtils.pas',
  PublicFieldIterator in '..\src\JSONMapper\PublicFieldIterator.pas',
  TestObjects in 'ObjectToJSON\TestObjects.pas',
  TestHelper in 'helper\TestHelper.pas',
  ObjektToJSON.BasicObject_Test in 'ObjectToJSON\ObjektToJSON.BasicObject_Test.pas',
  ObjectToJSON.IgnoreAttribute_Test in 'ObjectToJSON\ObjectToJSON.IgnoreAttribute_Test.pas',
  JSONToObject_Test in 'JSONToObject\JSONToObject_Test.pas',
  ObjectToJSON.NestedObject_Test in 'ObjectToJSON\ObjectToJSON.NestedObject_Test.pas',
  ObjectToJSON.GenericList_Test in 'ObjectToJSON\ObjectToJSON.GenericList_Test.pas',
  JSONMapper.EnumerableHelper in '..\src\JSONMapper\JSONMapper.EnumerableHelper.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
begin
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
