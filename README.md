# hottie_next

Demo of running flutter tests in hot reload mode. Just run this project in VSCode by pressing F5. It can also be launched from terminal:
```sh
flutter run test/runner.dart -d flutter-tester
```

Once it's running, change anything, for example make test fail, and see what happens.

### Ideas

- Skip unnecessary test executions:
    - if only *_test.dart file changed, only this one file needs to be relaunched
    - if some tests failed in previous run, then it does not make sense to run entire suite again until they are fixed
    - see if we can track dependencies of every test file

- Limit amount of isolates
    - group tests together (super simple)
    - see how long each test file takes and group them in isolated, such that they roughly take the same time
    - see how long it takes to run all tests in one isolate, then see if more isolates speeds things up

- Provide better output:
    - Redirect the prints somehow
    - Measure time taken for all tests