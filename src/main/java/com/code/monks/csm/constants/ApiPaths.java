package com.code.monks.csm.constants;

public class ApiPaths {

    public static final String CONTEXT = "/csm";

    public static final String BASE = CONTEXT + "/api/v1";

    public static final String ADD_USER = "/user/add";

    public static final String GET_USERS = "/users/get";

    public static final String GET_ENCRYPTED_USER_DETAIL = "/get/user/detail/{userId}";

    public static final String DELETE_USER = "/user/delete/{userId}";

    public static final String LOGIN = "/login";

    public static final String ADD_STAFF = "/staff/add";

    public static final String GET_STAFF = "/staffs/get";
    public static final String GET_STAFF_V2 = "/staffs/get/all";

    public static final String SEARCH_STAFFS = "/staffs/search";
    public static final String GET_STAFF_BY_ID = "/staff/{staffId}";
    public static final String UPDATE_STAFF = "/staff/{staffId}";
    public static final String DELETE_STAFF = "/staff/delete";

    public static final String ADD_CUSTOMER = "/customer/add";

    public static final String CUSTOMER_LIST_WITH_PAGINATION = "/customers/get";
    public static final String GET_ALL_CUSTOMERS = "/customers/get/all";
    public static final String UPDATE_CUSTOMER = "/customers/update/id/{id}";
    public static final String GET_CUSTOMER_BY_ID ="/customers/get/id/{id}";

    public static final String DELETE_CUSTOMER = "/customer/delete";

    public static final String SEARCH_CUSTOMERS = "/customers/search";

    public static final String ADD_SUPPLIER = "/supplier/add";

    public static final String DELETE_SUPPLIER = "/supplier/delete";
    public static final String GET_SUPPLIER_BY_ID = "/suppliers/get/id/{id}";


    public static final String ADD_BILL = "/bill/entry/add";
    public static final String UPDATE_BILL_ENTRY = "/bill/entry/update/{id}";
    public static final String SEARCH_BILL_ENTRY = "bill/entries/search";
    public static final String DELETE_BILL_ENTRY = "bill/entry/delete";
    public static final String GET_BILL_DETAILS = "/bill/{billNumber}";

    public static final String ADD_CREDIT_ENTRY = "/credit/entry/add";

    public static final String GET_CREDIT_ENTRIES = "/credit/entries/get";

    public static final String SEARCH_CREDIT_ENTRIES = "/credit/entries/search";
    public static final String UPDATE_CREDIT_ENTRY = "/credit/entry/update/{id}";
    public static final String DELETE_CREDIT_ENTRY ="/credit/entry/delete/{id}";
    public static final String GET_CREDIT_DETAILS = "/credit/details/{id}";

    public static final String SEARCH_USER = "/users/search";

    public static final String SUPPLIERS_LIST_WITH_PAGINATION = "/suppliers/get";
    public static final String GET_ALL_SUPPLIERS = "/suppliers/get/all";
    public static final String SEARCH_SUPPLIERS = "/suppliers/search";
    public static final String SEARCH_SUPPLIERS_V2 = "/suppliers/search/v2";
    public static final String UPDATE_SUPPLIER = "/suppliers/update/id/{id}";

    public static final String ADD_PURCHASE_ENTRY = "/purchase/entry/add";

    public static final String SEARCH_PURCHASE_ENTRIES = "/purchase/entries/search";
    public static final String UPDATE_PURCHASE_ENTRY="purchase/entry/update/{id}";
    public static final String DELETE_PURCHASE_ENTRY = "/purchase/entry/delete/{id}";
    public static final String GET_PURCHASE_DETAILS_BY_ID ="/purchase/get/details/{id}";
    public static final String GET_COPY_SUPPLIER_DETAILS_PER_CUSTOMER= "/purchase/copy-suppliers";

    public static final String TRANSPORT_SEARCH ="/transports/search";
    public static final String GET_ALL = "/transports/getAll";
    public static final String GET_ALL_TRANSPORT = "/transports/get/all";
    public static final String ADD_TRANSPORT = "/transports/add";
    public static final String UPDATE_TRANSPORT = "/transports/update/{id}";
    public static final String DELETE_TRANSPORT = "/transports/delete/{id}";
    public static final String GET_TRANSPORT_DETAILS = "/transports/{id}";

    public static final String CHANGE_PASSWORD = "/admin/change/password";

    // retailer
    public static final String RETAILER_ENTRY = "/retail/create";
    public static final String UPDATE_RETAILER = "/retail/{id}";
    public static final String GET_RETAILER = "/retail/get/{id}";
    public static final String SEARCH_RETAILERS = "/retail/search";
    public static final String GET_DEPOSIT_HISTORY = "/retail/{retailId}/deposits";
    public static final String ADD_DEPOSIT = "/retail-supplier-deposits";
    public static final String DELETE_RETAILER = "/retail/{retailId}";
    public static final String UPDATE_RETAIL_SUPPLIER ="/retail-suppliers/{retailSupplierId}";
    public static final String DELETE_RETAIL_SUPPLIER = "/retail-suppliers/{retailSupplierId}";
    public static final String ADD_RETAIL_SUPPLIER = "/retail-suppliers";

    // admin
    public static final String GET_CONFIGURATIONS = "/admin/configurations";
    public static final String UPDATE_CONFIGURATION = "/admin/configurations/{configurationId}";

    // ledger
    public static final String LEDGER = "/ledger";
    public static final String LEDGER_DOWNLOAD = "/ledger/download";

    // analytics
    public static final String ANALYTICS_MONTHLY = "/analytics/monthly";
    public static final String ANALYTICS_STAFF = "/analytics/staff";
    public static final String ANALYTICS_SUPPLIER_AMOUNT = "/analytics/supplier/amount";
    public static final String ANALYTICS_CUSTOMER_AMOUNT = "/analytics/customer/amount";

}
