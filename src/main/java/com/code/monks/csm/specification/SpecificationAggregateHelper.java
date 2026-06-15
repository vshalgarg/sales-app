package com.code.monks.csm.specification;

import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SpecificationAggregateHelper {

    private final EntityManager entityManager;

    public <T> Long sumRoundedAmount(
            Class<T> entityClass,
            String fieldName,
            Specification<T> specification
    ) {

        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> query = cb.createQuery(Long.class);
        Root<T> root = query.from(entityClass);
        Predicate predicate =
                specification.toPredicate(
                        root,
                        query,
                        cb
                );

        Expression<Number> amount =
                cb.quot(
                        root.get(fieldName),
                        100.0
                );

        query.select(
                cb.coalesce(
                        cb.sum(
                                cb.function(
                                        "ROUND",
                                        Long.class,
                                        amount
                                )
                        ),
                        0L
                )
        );

        if (predicate != null) {
            query.where(predicate);
        }

        return entityManager.createQuery(query).getSingleResult();
    }
}
