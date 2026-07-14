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

    public <T> Long sumAmount(
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

        query.select(
                cb.coalesce(
                        cb.sum(
                                root.get(fieldName)
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
