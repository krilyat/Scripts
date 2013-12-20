from time import strftime

import MySQLdb as mdb

con = mdb.connect('localhost', 'shout', 'shout', 'shoutbox_db')
imagesuffix = ["www.bonjourmadame.fr",
               "www.aurevoirmadame.fr",
               "bonjourlecul.fr"]
day = strftime('%d-%m-%Y')
with con:
    cur = con.cursor()
    for suffix in imagesuffix:
        cur.execute("insert into ajax_chat_messages (userName,dateTime,text)\
                    values ('BonjourMadame', curdate(),\
                    '[img]http://www.bonjourtous.fr/images/" + day + "/" +
                    suffix + "_large.jpg[/img]')")
