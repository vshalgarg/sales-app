package com.code.monks.csm.enums;

public enum UploadModuleEnum {
    BILTY("bilty"),
    PURCHASE("orderForm");

    private final String folder;

    UploadModuleEnum(String folder) {
        this.folder = folder;
    }

    public String getFolder() {
        return folder;
    }
}
