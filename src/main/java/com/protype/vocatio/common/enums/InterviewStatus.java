package com.protype.vocatio.common.enums;

import com.fasterxml.jackson.annotation.JsonValue;

public enum InterviewStatus {
    QUESTION("question"),
    FINISHED("finished");

    private final String value;

    InterviewStatus(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }
}
