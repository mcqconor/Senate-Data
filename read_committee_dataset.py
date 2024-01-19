#import necessary packages
import pandas as pd

#holding column
old_names = ['holder']

#Using this to map the party codes to the actual party names
party_codes = ['1','22','29','44','100','114','200','203','206','208','300','310','328','329','331','403','555','1111','1275','1346','3333',
               '4444','7777','8000','8888']
party_names = ['Federalist','John Q. Adams Democrat','Whig','Nullifier','Democrat','Readjuster','Republican','Unconditional Unionist',
               'Unionist','Liberal Republican','Free Soil','American','Independent','Independent and Democrat','Inedependent Republican',
               'Law and Order','Jackson','Liberty','Anti-Jackson','Jackson Republican','Opposition','Unionist','Crawford Republican',
               'Adams-Clay Federalist','Adams-Clay Republican']

#Put the party codes & names into a data frame
party_df = pd.DataFrame({'party_code':party_codes,'party':party_names})

#Using this to map state codes into the state postal abbreviations. 
state_codes = ['1','2','3','4','5','6','11','12','13','14','21','22','23','24','25','51','52','53','54','56','61','62','63','64',
               '65','66','67','68','31','32','33','34','35','36','37','41','42','43','44','45','46','47','48','49','40','71','72',
               '73','74','75']
#This can be changed into state names if desired
state = ['CT','ME','MA','NH','RI','VT','DE','NJ','NY','PA','IL','IN','MI','OH','WI','KY','MD','OK','TN','WV',
         'AZ','CO','ID','MT','NV','NM','UT','WY','IA','KS','MN','MO','NE','ND','SD','AL','AR','FL','GA','LA',
         'MS','NC','SC','TX','VA','CA','OR','WA','AK','HI']

state_df = pd.DataFrame({'state_code':state_codes,'state':state})

#Mapping senate committee codes to names. Names are reworked so are constant through time
#i.e. Even though the Commerce, Science, and Transportation committee has at times been called different things
#I make it as if its name were always Commerce, Science, and Transportation
sen_80_102_cc = ['302','304','305','306','308','313','314','316','320','321','324','328','342','344','330','332','336',
                 '338','348','362','352','354','358','363','370','372','374','380','384','388']
sen_80_102_c = ['Aeronautical and Space Sciences','Agriculture, Nutrition, and Forestry','Agriculture, Nutrition, and Forestry',
    'Appropriations','Armed Services','Banking, Housing and Urban Affairs','Banking, Housing and Urban Affairs','Budget',
    'Commerce, Science and Transportation','Commerce, Science and Transportation','District of Columbia','Governmental Affairs',
    'Governmental Affairs','Governmental Affairs','Energy and Natural Resources','Environment and Public Works',
    'Finance','Foreign Relations','Labor and Human Resources','Labor and Human Resources','Energy and Natural Resources',
    'Commerce, Science and Transportation','Judiciary','Labor and Human Resources','Post Office and Civil Service',
    'Energy and Natural Resources','Environment and Public Works','Rules and Administration','Small Business','Veterans Affairs']

sen_80_102_c_df = pd.DataFrame({'committee_code':sen_80_102_cc,'committee':sen_80_102_c})


#Read in Charles Stewart's data
sen_80_102 = pd.read_csv('https://web.mit.edu/cstewart/www/data/snc80102.mit', delimiter='\t', names=old_names)

#This section extracts every field I could manage, I only uncommented the fields I need for my dashboarding purpose

# sen_80_102['code'] = sen_80_102['holder'].str[0:2]
# sen_80_102['office'] = sen_80_102['holder'].str[2:3]
sen_80_102['state_code'] = sen_80_102['holder'].str[3:5].str.strip()
# sen_80_102['senate_class'] = sen_80_102['holder'].str[5:7]
# sen_80_102['occupancy'] = sen_80_102['holder'].str[7:8]
# sen_80_102['attainment'] = sen_80_102['holder'].str[8:9]
sen_80_102['party_code'] = sen_80_102['holder'].str[10:13].str.strip()
# sen_80_102['service'] = sen_80_102['holder'].str[13:14]
sen_80_102['icpsr_id'] = sen_80_102['holder'].str[15:19].str.strip()
sen_80_102['name'] = sen_80_102['holder'].str[20:45].str.strip()
sen_80_102['congress'] = sen_80_102['holder'].str[47:50].str.strip()
sen_80_102['committee_code'] = sen_80_102['holder'].str[50:53].str.strip()
sen_80_102['party_status'] = sen_80_102['holder'].str[53:54].str.strip()
sen_80_102['committee_party_rank'] = sen_80_102['holder'].str[54:56].str.strip()
# sen_80_102['senior_party_status'] = sen_80_102['holder'].str[56:58].str.strip()
# sen_80_102['chamber_seniority'] = sen_80_102['holder'].str[58:60]
# sen_80_102['committee_service_period'] = sen_80_102['holder'].str[60:61]
# sen_80_102['committee_seniority'] = sen_80_102['holder'].str[61:63]
# sen_80_102['order_of_assignment'] = sen_80_102['holder'].str[63:65]
sen_80_102 = sen_80_102.drop(['holder'], axis = 1)

#join on the coding dfs made earlier
sen_80_102 = sen_80_102.merge(party_df, on='party_code', how='left').merge(state_df, on='state_code', how = 'left').drop(['party_code','state_code'], axis=1)
sen_80_102 = sen_80_102.merge(sen_80_102_c_df, on='committee_code', how = 'left').drop(['committee_code'], axis = 1)

#save to a csv
sen_80_102.to_csv('80 to 102 committees.csv')

#Consider this an element left to the reader. The data exists for the 49th-79th congresses, however I have not
#fully worked out the committee names for this period yet. The state data is also missing so I had to collect that
#by hand

# sen_49_79 = pd.read_csv('https://web.mit.edu/cstewart/www/data/sst4979.dat', delimiter='\t', names=old_names)

# sen_49_79['congress'] = sen_49_79['holder'].str[0:2].str.strip()
# sen_49_79['committee_code'] = sen_49_79['holder'].str[2:6].str.strip()
# sen_49_79['icpsr_id'] = sen_49_79['holder'].str[6:11].str.strip()
# sen_49_79['name'] = sen_49_79['holder'].str[11:36].str.strip()
# sen_49_79['party_status'] = sen_49_79['holder'].str[36:37].str.strip()
# sen_49_79['committee_rank'] = sen_49_79['holder'].str[37:39].str.strip()
# sen_49_79['date_appointed'] = sen_49_79['holder'].str[39:47].str.strip()
# sen_49_79['date_terminated'] = sen_49_79['holder'].str[47:56].str.strip()
# sen_49_79['party'] = sen_49_79['holder'].str[56:].str.strip()
# sen_49_79 = sen_49_79.drop(['holder'], axis = 1)

