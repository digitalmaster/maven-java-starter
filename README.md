# Application

## Quality of Life Tools

Lombok for easier, less verbose Java data classes

## Logging

Logging is enabled through the SLF4J API and implemented through Logback. The Logback
implementation includes a Daily Rolling File with file sifting enabled through the value
of the `MDC` value. This appender is also asynchronous for speed purposes

## Testing

Testing is enabled through JUnit with AssertJ for the assertions library. Unit tests
are enabled by default and integration tests are skipped. There is a profile
called `ci` which runs both and can be enabled by passing the `-P` parameter such as:

```
mvn clean verify -P ci
```
