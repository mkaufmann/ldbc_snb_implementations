create procedure LdbcUpdate1AddPerson (in personid int,
       		 		       in personfirstname varchar,
				       in personlastname varchar,
				       in gender varchar,
				       in birthday varchar,
				       in creationdate varchar,
				       in locationip varchar,
				       in browserused varchar,
				       in cityid int, 
				       in languages varchar array,
				       in emails varchar array,
				       in tagids int array,
				       in studyatorgids int array,
				       in studyatyears int array,
				       in workatorgids int array,
				       in workatyears int array
				       )
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	insert into person values(personid, personfirstname, personlastname, gender,
	       	    	   	  stringdate(birthday), stringdate(creationdate),
				  bit_or(
					bit_or( bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[0], 24),
					       bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[1], 16)),
					bit_or( bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[2], 8),
					       sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[3])
       				  ),
				  browserused, cityid, null);
	for vectored
	    (in i1 varchar := languages) {
	    insert into person_language values(personid, i1);
	}
	for vectored
	    (in i1 varchar := emails) {
	    insert into person_email values(personid, i1);
	}
	for vectored
	    (in i1 int := tagids) {
	    insert into person_tag values(personid, i1);
	}
	for vectored
	    (in i1 int := studyatorgids, in i2 int := studyatyears) {
	    insert into person_university values(personid, i1, i2);
	}
	for vectored
	    (in i1 int := workatorgids, in i2 int := workatyears) {
	    insert into person_company values(personid, i1, i2);
	}
	return;
};


create procedure LdbcUpdate2AddPostLike (in personid int,
       		 			 in postid int,
					 in datetimestr varchar
					 )
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	insert into likes values(personid, postid, stringdate(datetimestr));
	return;
};

create procedure LdbcUpdate4AddForum  (in forumid int,
       		 		       in forumtitle varchar,
				       in creationdate varchar,
				       in moderatorpersonid int, 
				       in tagids int array
				       )
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	insert into forum values(forumid, forumtitle, stringdate(creationdate), moderatorpersonid);
	for vectored
	    (in i1 int := tagids) {
	    insert into forum_tag values(forumid, i1);
	}
	return;
};

create procedure LdbcUpdate5AddForumMembership (in forumid int,
       		 			        in personid int,
						in creationdate varchar
					 	)
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	insert into forum_person values(forumid, personid, stringdate(creationdate));
	return;
};

create procedure LdbcUpdate6AddPost (in postid int,
       		 		     in imagefile varchar,
				     in creationdate varchar,
				     in locationip varchar,
				     in browserused varchar,
				     in lang varchar,
				     in content varchar,
				     in len int,
				     in authorpersonid int,
				     in forumid int,
				     in countryid int,
				     in tagids int array
				     )
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	insert into post values(postid, imagefile, stringdate(creationdate),
				  bit_or(
					bit_or( bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[0], 24),
					       bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[1], 16)),
					bit_or( bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[2], 8),
					       sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[3])
       				  ),
				browserused, lang, content, len, authorpersonid, countryid, forumid, NULL, NULL);
				
	for vectored
	    (in i1 int := tagids) {
	    insert into post_tag values(postid, i1);
	}

};

create procedure LdbcUpdate7AddComment (in commentid int,
				    	in creationdate varchar,
				     	in locationip varchar,
				     	in browserused varchar,
				     	in content varchar,
				     	in len int,
				     	in authorpersonid int,
				     	in countryid int,
					in replytopostid int,
					in replytocommentid int,
				     	in tagids int array
				     	)
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	insert into post values(commentid, NULL, stringdate(creationdate),
				  bit_or(
					bit_or( bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[0], 24),
					       bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[1], 16)),
					bit_or( bit_shift(sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[2], 8),
					       sprintf_inverse(locationip, '%d.%d.%d.%d', 2)[3])
       				  ),
				browserused, NULL, content, len, authorpersonid, countryid, NULL,
				replytocommentid+replytopostid+1,
				NULL);
				
	for vectored
	    (in i1 int := tagids) {
	    insert into post_tag values(commentid, i1);
	}

};
				     

create procedure LdbcUpdate8AddFriendship (in person1id int,
       		 			   in person2id int,
					   in creationdate varchar
					   )
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	insert into knows values(person1id, person2id, stringdate(creationdate));
	return;
};

create procedure LdbcUpdateSparql (in triplets varchar array)
{
	declare n_dead any;
	n_dead := 0;
	again:	
	declare exit handler for sqlstate '40001' {
		rollback work;
		n_dead := n_dead + 1;
		if (10 < n_dead) {
		   signal ('40001', 'Over 10 deadlocks in rdf load, please retry load');
		   return;
		}
		goto again;
	};
	for vectored
	    (in t varchar := triplets) {
	    ttlp_mt(t, '', 'sib', 0);
	}
	return;
};

create procedure post_view (in postid int) {
  declare content, imagefile varchar;
  declare creationdate datetime;
  result_names(content, imagefile, creationdate);

  whenever not found goto done1;
  declare cr1 cursor for 
      select ps_content, ps_imagefile, ps_creationdate
        from post
	where
	  ps_postid = postid;

  open cr1;
  while (1)
    {
      fetch cr1 into content, imagefile, creationdate;
      result (content, imagefile, creationdate);
    }

done1:
  close cr1;

  declare firstname, lastname varchar;
  declare personid int;
  result_names(personid, firstname, lastname);
  end_result ();

  whenever not found goto done2;
  declare cr2 cursor for 
      select p_personid, p_firstname, p_lastname
        from post, person
	where
	  ps_postid = postid and ps_creatorid = p_personid;

  open cr2;
  while (1)
    {
      fetch cr2 into personid, firstname, lastname;
      result (personid, firstname, lastname);
    }

done2:
  close cr2;

  declare modfirstname, modlastname, forumname varchar;
  declare modpersonid, forumid int;
  result_names(forumid, forumname, modpersonid, modfirstname, modlastname);
  end_result ();

  whenever not found goto done3;
  declare cr3 cursor for 
      select f_forumid, f_title, p_personid, p_firstname, p_lastname
        from post, person, forum
	where
	  ps_postid = postid and ps_forumid = f_forumid and f_moderatorid = p_personid;

  open cr3;
  while (1)
    {
      fetch cr3 into forumid, forumname, modpersonid, modfirstname, modlastname;
      result (forumid, forumname, modpersonid, modfirstname, modlastname);
    }

done3:
  close cr3;

  declare origpostcontent, origfirstname, origlastname varchar;
  declare origpostid, origautorid, friendornot int;
  result_names(origpostid, origpostcontent, origautorid, origfirstname, origlastname, friendornot);
  end_result ();

  whenever not found goto done4;
  declare cr4 cursor for 
      select p2.ps_postid, p2.ps_content, p_personid, p_firstname, p_lastname,
      	     (case when exists (
	     	   	       select 1 from knows
			       where p1.ps_creatorid = k_person1id and p2.ps_creatorid = k_person2id)
	      then 1
	      else 0
	      end)
        from post p1, post p2, person
	where
	  p1.ps_postid = postid and p1.ps_replyof = p2.ps_postid and p2.ps_creatorid = p_personid;

  open cr4;
  while (1)
    {
      fetch cr4 into origpostid, origpostcontent, origautorid, origfirstname, origlastname, friendornot;
      result (origpostid, origpostcontent, origautorid, origfirstname, origlastname, friendornot);
    }

done4:
  close cr4;

}

create procedure post_view_1 (in postid int) {
  declare content, imagefile varchar;
  declare creationdate datetime;
  result_names(content, imagefile, creationdate);

  whenever not found goto done1;
  declare cr1 cursor for 
      select ps_content, ps_imagefile, ps_creationdate
        from post
	where
	  ps_postid = postid;

  open cr1;
  while (1)
    {
      fetch cr1 into content, imagefile, creationdate;
      result (content, imagefile, creationdate);
    }

done1:
  close cr1;
}

create procedure post_view_2 (in postid int) {
  declare firstname, lastname varchar;
  declare personid int;
  result_names(personid, firstname, lastname);

  whenever not found goto done2;
  declare cr2 cursor for 
      select p_personid, p_firstname, p_lastname
        from post, person
	where
	  ps_postid = postid and ps_creatorid = p_personid;

  open cr2;
  while (1)
    {
      fetch cr2 into personid, firstname, lastname;
      result (personid, firstname, lastname);
    }

done2:
  close cr2;
}


create procedure post_view_3 (in postid int) {
  declare modfirstname, modlastname, forumname varchar;
  declare modpersonid, forumid int;
  result_names(forumid, forumname, modpersonid, modfirstname, modlastname);

  whenever not found goto done3;
  declare cr3 cursor for 
      select f_forumid, f_title, p_personid, p_firstname, p_lastname
        from post, person, forum
	where
	  ps_postid = postid and ps_forumid = f_forumid and f_moderatorid = p_personid;

  open cr3;
  while (1)
    {
      fetch cr3 into forumid, forumname, modpersonid, modfirstname, modlastname;
      result (forumid, forumname, modpersonid, modfirstname, modlastname);
    }

done3:
  close cr3;
}

create procedure post_view_4 (in postid int) {
  declare origpostcontent, origfirstname, origlastname varchar;
  declare origpostid, origautorid, friendornot int;
  result_names(origpostid, origpostcontent, origautorid, origfirstname, origlastname, friendornot);

  whenever not found goto done4;
  declare cr4 cursor for 
      select p2.ps_postid, p2.ps_content, p_personid, p_firstname, p_lastname,
      	     (case when exists (
	     	   	       select 1 from knows
			       where p1.ps_creatorid = k_person1id and p2.ps_creatorid = k_person2id)
	      then 1
	      else 0
	      end)
        from post p1, post p2, person
	where
	  p1.ps_postid = postid and p2.ps_replyof = p1.ps_postid and p2.ps_creatorid = p_personid;

  open cr4;
  while (1)
    {
      fetch cr4 into origpostid, origpostcontent, origautorid, origfirstname, origlastname, friendornot;
      result (origpostid, origpostcontent, origautorid, origfirstname, origlastname, friendornot);
    }

done4:
  close cr4;
}


create procedure person_view (in personid int) {
  declare firstname, lastname, gender, browserused varchar;
  declare birthday, creationdate datetime;
  declare locationip, placeid int;
  result_names(firstname, lastname, gender, birthday, creationdate, locationip, browserused, placeid);

  whenever not found goto done1;
  declare cr1 cursor for 
      select p_firstname, p_lastname, p_gender, p_birthday, p_creationdate, p_locationip, p_browserused, p_placeid
        from person
	where
	  p_personid = personid;

  open cr1;
  while (1)
    {
      fetch cr1 into firstname, lastname, gender, birthday, creationdate, locationip, browserused, placeid;
      result (firstname, lastname, gender, birthday, creationdate, locationip, browserused, placeid);
    }

done1:
  close cr1;

  declare content, imagefile, origfirstname, origlastname varchar;
  declare postid, origpostid, origpersonid int;
  declare postcreationdate datetime;
  result_names(postid, content, imagefile, postcreationdate, origpostid, origpersonid, origfirstname, origlastname);
  end_result ();

  whenever not found goto done2;
  declare cr2 cursor for 
    select p1.ps_postid, p1.ps_content, p1.ps_imagefile, p1.ps_creationdate,
           p2.ps_postid, p2.p_personid, p2.p_firstname, p2.p_lastname
    from 
         (select top 10 ps_postid, ps_content, ps_imagefile, ps_creationdate, ps_replyof
          from post
          where ps_creatorid = personid
          order by ps_creationdate desc
         ) p1
         left outer join
         (select ps_postid, p_personid, p_firstname, p_lastname
          from post, person
          where ps_creatorid = p_personid
         )p2  
         on p2.ps_postid = p1.ps_replyof;

  open cr2;
  while (1)
    {
      fetch cr2 into postid, content, imagefile, postcreationdate, origpostid, origpersonid, origfirstname, origlastname;
      result (postid, content, imagefile, postcreationdate, origpostid, origpersonid, origfirstname, origlastname);
    }

done2:
  close cr2;

  declare friendfirstname, friendlastname varchar;
  declare friendpersonid int;
  declare since datetime;
  result_names(friendpersonid, friendfirstname, friendlastname, since);
  end_result ();

  whenever not found goto done3;
  declare cr3 cursor for 
      select p_personid, p_firstname, p_lastname, k_creationdate
        from knows, person
	where
	  k_person1id = personid and k_person2id = p_personid;

  open cr3;
  while (1)
    {
      fetch cr3 into friendpersonid, friendfirstname, friendlastname, since;
      result (friendpersonid, friendfirstname, friendlastname, since);
    }

done3:
  close cr3;

}

create procedure person_view_1 (in personid int) {
  declare firstname, lastname, gender, browserused, locationip varchar;
  declare birthday, creationdate datetime;
  declare placeid int;
  result_names(firstname, lastname, gender, birthday, creationdate, locationip, browserused, placeid);

  whenever not found goto done1;
  declare cr1 cursor for 
      select p_firstname, p_lastname, p_gender, p_birthday, p_creationdate,
      	     bit_shift(bit_and(p_locationip, 4278190080), -24) || '.' ||
       	     bit_shift(bit_and(p_locationip, 16711680), -16) || '.' ||
       	     bit_shift(bit_and(p_locationip, 65280), -8) || '.' ||
       	     bit_and(p_locationip, 255),
	     p_browserused, p_placeid
        from person
	where
	  p_personid = personid;

  open cr1;
  while (1)
    {
      fetch cr1 into firstname, lastname, gender, birthday, creationdate, locationip, browserused, placeid;
      result (firstname, lastname, gender, birthday, creationdate, locationip, browserused, placeid);
    }

done1:
  close cr1;
}

create procedure person_view_2 (in personid int) {
  declare content, imagefile, origfirstname, origlastname varchar;
  declare postid, origpostid, origpersonid int;
  declare postcreationdate datetime;
  result_names(postid, content, imagefile, postcreationdate, origpostid, origpersonid, origfirstname, origlastname);

  whenever not found goto done2;
  declare cr2 cursor for 
    select p1.ps_postid, p1.ps_content, p1.ps_imagefile, p1.ps_creationdate,
           p2.ps_postid, p2.p_personid, p2.p_firstname, p2.p_lastname
    from 
         (select top 10 ps_postid, ps_content, ps_imagefile, ps_creationdate, ps_replyof
          from post
          where ps_creatorid = personid
          order by ps_creationdate desc
         ) p1
         left outer join
         (select ps_postid, p_personid, p_firstname, p_lastname
          from post, person
          where ps_creatorid = p_personid
         )p2  
         on p2.ps_postid = p1.ps_replyof;

  open cr2;
  while (1)
    {
      fetch cr2 into postid, content, imagefile, postcreationdate, origpostid, origpersonid, origfirstname, origlastname;
      result (postid, content, imagefile, postcreationdate, origpostid, origpersonid, origfirstname, origlastname);
    }

done2:
  close cr2;
}

create procedure person_view_3 (in personid int) {
  declare friendfirstname, friendlastname varchar;
  declare friendpersonid int;
  declare since datetime;
  result_names(friendpersonid, friendfirstname, friendlastname, since);

  whenever not found goto done3;
  declare cr3 cursor for 
      select p_personid, p_firstname, p_lastname, k_creationdate
        from knows, person
	where
	  k_person1id = personid and k_person2id = p_personid;

  open cr3;
  while (1)
    {
      fetch cr3 into friendpersonid, friendfirstname, friendlastname, since;
      result (friendpersonid, friendfirstname, friendlastname, since);
    }

done3:
  close cr3;
}
