CREATE TABLE track_time_tpl
(
    createdDate      TIMESTAMP NOT NULL,
    updatedDate      TIMESTAMP,
    deletedDate      TIMESTAMP,
    lastModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE blog_user
(
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activatedDate TIMESTAMP,
    email         VARCHAR NOT NULL UNIQUE,
    username      VARCHAR NOT NULL UNIQUE,
    password      VARCHAR NOT NULL
) INHERITS (track_time_tpl);

CREATE TABLE blog
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content    VARCHAR NOT NULL,
    title      VARCHAR NOT NULL,
    authoredBy UUID    NOT NULL
) INHERITS (track_time_tpl);
ALTER TABLE blog
    ADD CONSTRAINT authored_by_fk FOREIGN KEY (authoredby) REFERENCES blog_user ON DELETE CASCADE;

CREATE TABLE tag
(
    id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    keyword VARCHAR NOT NULL UNIQUE
);

CREATE TABLE role
(
    id   INTEGER PRIMARY KEY,
    name VARCHAR NOT NULL UNIQUE
);

CREATE TABLE user_role
(
    userId UUID    NOT NULL,
    roleId INTEGER NOT NULL
);
ALTER TABLE user_role
    ADD CONSTRAINT user_id_fk FOREIGN KEY (userId) REFERENCES blog_user ON DELETE CASCADE;
ALTER TABLE user_role
    ADD CONSTRAINT role_id_fk FOREIGN KEY (roleId) REFERENCES role ON DELETE CASCADE;
ALTER TABLE user_role
    ADD CONSTRAINT user_role_pk PRIMARY KEY (userId, roleId);

CREATE TABLE blog_tag
(
    blogId UUID NOT NULL,
    tagId  UUID NOT NULL
);
ALTER TABLE blog_tag
    ADD CONSTRAINT blog_id_fk FOREIGN KEY (blogId) REFERENCES blog_user ON DELETE CASCADE;
ALTER TABLE blog_tag
    ADD CONSTRAINT tag_id_fk FOREIGN KEY (tagId) REFERENCES tag ON DELETE CASCADE;
ALTER TABLE blog_tag
    ADD CONSTRAINT blog_tag_pk PRIMARY KEY (blogId, tagId);

CREATE TABLE comment
(
    id      UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    content VARCHAR          NOT NULL,
    blogId  UUID             NOT NULL,
    userId  UUID             NOT NULL
) INHERITS(track_time_tpl);
ALTER TABLE comment
    ADD CONSTRAINT blog_id_fk FOREIGN KEY (blogId) REFERENCES blog ON DELETE CASCADE;
ALTER TABLE comment
    ADD CONSTRAINT user_id_fk FOREIGN KEY (userId) REFERENCES blog_user ON DELETE CASCADE;

CREATE TABLE following
(
    userId     UUID NOT NULL,
    followerId UUID NOT NULL
);
ALTER TABLE following
    ADD CONSTRAINT user_id_fk FOREIGN KEY (userId) REFERENCES blog_user ON DELETE CASCADE;
ALTER TABLE following
    ADD CONSTRAINT follower_id_fk FOREIGN KEY (followerId) REFERENCES blog_user ON DELETE CASCADE;
ALTER TABLE following
    ADD CONSTRAINT following_pk PRIMARY KEY (userId, followerId);

CREATE TABLE history
(
    userId UUID NOT NULL,
    blogId UUID NOT NULL
);
ALTER TABLE history
    ADD CONSTRAINT user_id_fk FOREIGN KEY (userId) REFERENCES blog_user ON DELETE CASCADE;
ALTER TABLE history
    ADD CONSTRAINT blog_id_fk FOREIGN KEY (blogId) REFERENCES blog ON DELETE CASCADE;
ALTER TABLE history
    ADD CONSTRAINT history_pk PRIMARY KEY (userId, blogId);

CREATE TABLE reply
(
    replyId   UUID NOT NULL,
    commentId UUID NOT NULL
);
ALTER TABLE reply
    ADD CONSTRAINT reply_id_fk FOREIGN KEY (replyId) REFERENCES comment ON DELETE CASCADE;
ALTER TABLE reply
    ADD CONSTRAINT comment_id_fk FOREIGN KEY (commentId) REFERENCES comment ON DELETE CASCADE;
ALTER TABLE reply
    ADD CONSTRAINT reply_pk PRIMARY KEY (replyId, commentId);

CREATE TABLE review
(
    blogId UUID    NOT NULL,
    userId UUID    NOT NULL,
    rating INTEGER NOT NULL
);
ALTER TABLE review
    ADD CONSTRAINT blog_id_fk FOREIGN KEY (blogId) REFERENCES blog ON DELETE CASCADE;
ALTER TABLE review
    ADD CONSTRAINT user_id_fk FOREIGN KEY (userId) REFERENCES blog_user ON DELETE CASCADE;
ALTER TABLE review
    ADD CONSTRAINT review_pk PRIMARY KEY (blogId, userId);
