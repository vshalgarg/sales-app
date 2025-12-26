package com.code.monks.csm.constants;

public class ApiPaths {

    public static final String CONTEXT = "/csm";

    public static final String BASE = CONTEXT + "/api/v1";

    public static final String ADD_USER = "/user/add";

    public static final String GET_USERS = "/users/get";

    public static final String GET_ENCRYPTED_USER_DETAIL = "/get/user/detail/{userId}";

    public static final String DELETE_USER = "/user/delete";

    public static final String LOGIN = "/login";

    public static final String ADD_STAFF = "/staff/add";

    public static final String GET_STAFF = "/staffs/get";

    public static final String SEARCH_STAFFS = "/staffs/search";

    public static final String DELETE_STAFF = "/staff/delete";

    public static final String ADD_CUSTOMER = "/customer/add";

    public static final String GET_CUSTOMERS = "/customers/get";
    public static final String GET_CUSTOMERS_V2 = "/customers/get/all";

    public static final String DELETE_CUSTOMER = "/customer/delete";

    public static final String SEARCH_CUSTOMERS = "/customers/search";

    public static final String ADD_SUPPLIER = "/supplier/add";

    public static final String DELETE_SUPPLIER = "/supplier/delete";

    public static final String ADD_BILL = "/bill/entry/add";

    public static final String GET_BILL_ENTRIES = "/bill/entries/get";

    public static final String UPDATE_BILL_ENTRY = "/bill/entry/update/{billNumber}";

    public static final String SEARCH_BILL_ENTRY = "bill/entries/search";

    public static final String ADD_CREDIT_ENTRY = "/credit/entry/add";

    public static final String GET_CREDIT_ENTRIES = "/credit/entries/get";

    public static final String SEARCH_CREDIT_ENTRIES = "/credit/entries/search";

    public static final String SEARCH_USER = "/users/search";

    public static final String GET_SUPPLIERS = "/suppliers/get";
    public static final String GET_SUPPLIERS_V2 = "/suppliers/get/all";
    public static final String SEARCH_SUPPLIERS = "/suppliers/search";
    public static final String SEARCH_SUPPLIERS_V2 = "/suppliers/search/v2";

    public static final String ADD_PURCHASE_ENTRY = "/purchase/entry/add";

    public static final String SEARCH_PURCHASE_ENTRIES = "/purchase/entries/search";

    public static final String TRANSPORT_SEARCH ="/transports/search";
    public static final String GET_ALL = "/transports/getAll";
    public static final String GET_ALL_TRANSPORT = "/transports/get/all";
    public static final String ADD_TRANSPORT = "/transports/add";
    public static final String UPDATE_TRANSPORT = "/transports/update";
    public static final String DELETE_TRANSPORT = "/transports/delete/{id}";
}
