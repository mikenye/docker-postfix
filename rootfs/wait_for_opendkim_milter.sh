#!/usr/bin/env bash

EXITCODE=1
while [ "$EXITCODE" -ne "0" ]; do
    echo "Waiting for opendkim milter to become ready..."
    cat << EOF | miltertest > /dev/null 2>&1 
        -- Echo that the test is starting 
        mt.echo("*** begin test ***") 
        -- try to connect to it 
        conn = mt.connect("inet:8891@localhost") 
        if conn == nil then
            error "mt.connect() failed"
        end
        mt.echo("*** connected ***") 
        -- send connection information 
        -- mt.negotiate() is called implicitly 
        if mt.conninfo(conn, "localhost", "127.0.0.1") ~= nil then
            error "mt.conninfo() failed"
        end 
        if mt.getreply(conn) ~= SMFIR_CONTINUE then
            error "mt.conninfo() unexpected reply"
        end
        mt.echo("*** sent connection information ***") 
        -- send envelope macros and sender data 
        -- mt.helo() is called implicitly 
        mt.macro(conn, SMFIC_MAIL, "i", "test-id") 
        if mt.mailfrom(conn, "user@example.com") ~= nil then
            error "mt.mailfrom() failed"
        end 
        if mt.getreply(conn) ~= SMFIR_CONTINUE then
            error "mt.mailfrom() unexpected reply"
        end
        mt.echo("*** send envelope macros and sender data ***") 
        -- send headers 
        -- mt.rcptto() is called implicitly 
        if mt.header(conn, "From", "user@example.com") ~= nil then
            error "mt.header(From) failed"
        end 
        if mt.getreply(conn) ~= SMFIR_CONTINUE then
            error "mt.header(From) unexpected reply"
        end 
        if mt.header(conn, "Date", "Tue, 22 Dec 2009 13:04:12 −0800") ~= nil then
            error "mt.header(Date) failed"
        end 
        if mt.getreply(conn) ~= SMFIR_CONTINUE then
            error "mt.header(Date) unexpected reply"
        end 
        if mt.header(conn, "Subject", "Signing test") ~= nil then
            error "mt.header(Subject) failed"
        end 
        if mt.getreply(conn) ~= SMFIR_CONTINUE then
            error "mt.header(Subject) unexpected reply"
        end
        mt.echo("*** sent headers ***") 
        -- wrap it up! 
        mt.disconnect(conn)
        mt.echo("*** disconnected ***")
EOF
    EXITCODE=$?
    sleep 1
done

echo "opendkim milter is ready!"