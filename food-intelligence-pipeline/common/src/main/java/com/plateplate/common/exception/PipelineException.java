package com.plateplate.common.exception;

public class PipelineException extends RuntimeException {
    private final String errorCode;
    private final Object errorDetails;

    public PipelineException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
        this.errorDetails = null;
    }

    public PipelineException(String message, String errorCode, Object errorDetails) {
        super(message);
        this.errorCode = errorCode;
        this.errorDetails = errorDetails;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public Object getErrorDetails() {
        return errorDetails;
    }
}
