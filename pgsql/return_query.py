from __future__ import generators
import psycopg2

class ReturnQuery(object):
    def  __init__(self, dbname, user, password):
        self.dbname = dbname
        self.user= user
        self.password = password
        self.c = self.connect()

    def connect(self):
        self.con = psycopg2.connect("dbname="+self.dbname+" user="+self.user+" 
                                     password="+self.password)
        self.cur = self.con.cursor()
        return self.cur

    def func_with_no_result_gen(self):
        self.c.execute("select * from no_results()")
        for item in self.c:
            yield item

    def func_with_no_result_count(self):
        self.c.execute("select * from no_results()")
        return self.c.rowcount

    def func_with_single_row_gen(self):
        self.c.execute("select * from single_row()")
        for item in self.c:
            yield item

    def func_with_single_row_count(self):
        self.c.execute("select * from single_row()")
        return self.c.rowcount

    def func_with_filter(self, filters):
        self.c.execute("select * from genre_names() where "+ filters)
        return self.c.rowcount

# http://archives.postgresql.org/pgsql-bugs/2009-07/msg00072.php
