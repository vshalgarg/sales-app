package com.code.monks.csm.entity;

import com.code.monks.csm.context.RequestContext;
import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@MappedSuperclass
public class BaseEntity {

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "created_by", updatable = false)
    private Long createdBy;

    @Column(name = "updated_by")
    private Long updatedBy;

    @PrePersist
    public void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = createdAt;

        Long userId = getCurrentUserId();
        this.createdBy = userId;
        this.updatedBy = userId;
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        this.updatedBy = getCurrentUserId();
    }

    private Long getCurrentUserId() {
        return RequestContext.getRequiredUser().getUserId();
    }
}
