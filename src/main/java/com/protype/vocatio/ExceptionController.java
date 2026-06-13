package com.protype.vocatio;

import com.protype.vocatio.common.exceptions.BadRequestException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.net.URI;

@RestControllerAdvice
public class ExceptionController {
    private final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(ExceptionController.class);

    @ExceptionHandler(value = Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ProblemDetail genericException(Exception exception) {
        ProblemDetail problemDetail = ProblemDetail.forStatus(HttpStatus.INTERNAL_SERVER_ERROR);
        problemDetail.setTitle("Ups, algo pasó");
        problemDetail.setDetail(exception.getMessage());
        problemDetail.setType(URI.create("https://developer.mozilla.org/es/docs/Web/HTTP/Status/500"));
        log.info("exception Exception{}", exception.getMessage());
        return problemDetail;
    }

    @ExceptionHandler(value = RuntimeException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ProblemDetail runtimeException(RuntimeException exception) {
        ProblemDetail problemDetail = ProblemDetail.forStatus(HttpStatus.INTERNAL_SERVER_ERROR);
        problemDetail.setTitle("Ocurrió un inconveniente");
        problemDetail.setDetail("Si el inconveniente persiste, contacte con el administrador");
        problemDetail.setType(URI.create("https://developer.mozilla.org/es/docs/Web/HTTP/Status/500"));
        log.error("Error caused by {}", exception.toString() + " " + exception);
        return problemDetail;
    }

    @ExceptionHandler(value = BadRequestException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ProblemDetail requestException(BadRequestException exception) {
        ProblemDetail problemDetail = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
        problemDetail.setTitle("Ups, algo pasó");
        problemDetail.setDetail(exception.getMessage());
        problemDetail.setType(URI.create("https://developer.mozilla.org/es/docs/Web/HTTP/Status/400"));
        log.info("Exception RequestException: {}", exception.getMessage());
        return problemDetail;
    }

}
