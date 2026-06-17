package com.code.monks.csm.specification;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;

public class GenericSpecificationBuilder<T> {

    private Specification<T> spec;

    public GenericSpecificationBuilder() {
        spec = (root, query, cb) -> cb.conjunction();
    }

    public GenericSpecificationBuilder<T> fromDate(String field, LocalDate fromDate) {
        if (fromDate != null) {
            spec = spec.and((root, query, cb) ->
                    cb.greaterThanOrEqualTo(root.get(field), fromDate));
        }
        return this;
    }

    public GenericSpecificationBuilder<T> toDate(String field, LocalDate toDate) {
        if (toDate != null) {
            spec = spec.and((root, query, cb) ->
                    cb.lessThanOrEqualTo(root.get(field), toDate));
        }
        return this;
    }

    public GenericSpecificationBuilder<T> equal(String field, Object value) {
        if (value != null) {
            spec = spec.and((root, query, cb) ->
                    cb.equal(root.get(field), value));
        }
        return this;
    }

    public GenericSpecificationBuilder<T> joinEqual(String joinField, String field, Object value) {
        if (value != null) {
            spec = spec.and((root, query, cb) ->
                    cb.equal(root.join(joinField, JoinType.LEFT).get(field), value));
        }
        return this;
    }

    public Specification<T> build() {
        return spec;
    }

    public GenericSpecificationBuilder<T> joinJoinEqual(
            String firstJoin,
            String secondJoin,
            String field,
            Object value
    ) {

        if (value != null) {
            spec = spec.and((root, query, cb) -> {
                query.distinct(true);
                return cb.equal(
                        root.join(firstJoin, JoinType.LEFT)
                                .join(secondJoin, JoinType.LEFT)
                                .get(field),
                        value
                );
            });
        }
        return this;
    }
}
