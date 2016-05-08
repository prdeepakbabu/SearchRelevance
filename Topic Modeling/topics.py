# -*- coding: utf-8 -*-
"""
Created on Mon May  2 13:21:08 2016

@author: deepak
"""
import gensim
from gensim import corpora, models
import os
import pandas as pd
import numpy as np
import sys
#sys.path.append('/usr/local/lib/python2.7/dist-packages')
from bs4 import BeautifulSoup   
import nltk
from nltk.corpus import stopwords
import re
from nltk.stem.wordnet import WordNetLemmatizer
lmtzr = WordNetLemmatizer()

def review_to_words(raw_review ):
    review_text = BeautifulSoup(raw_review).get_text()
    tmp = re.sub(","," ",review_text);
    words = tmp.lower().split()                             
    stops = set(stopwords.words("english"))                  
    meaningful_words = [str(lmtzr.lemmatize(w)) for w in words if not w in stops ]        
    res = [None] * len(meaningful_words); counter = 0;
    for i in meaningful_words:
        if re.match("[a-z]+[0-9]+",i) :
            tmp = re.sub("[0-9]+","[d]",i)
            tmp1 = re.sub("[a-z]+","[c]",tmp)
            res[counter] = tmp1
        else:
            res[counter]= i
        counter = counter + 1
    #return( " ".join( res ))   
    return(res)   

os.chdir("/home/deepak/Documents/Projects/TopicModeling")
train = pd.read_csv("vis2_min20.csv", header=1,delimiter=",",encoding ='UTF-8');
train.columns=['query','visits','orders']
num_rows = train["query"].size
clean_query = []

for i in xrange( 0, num_rows ):
    try:
        clean_query.append( review_to_words( train["query"][i] ) )
    except:
        pass

# remove words that appear only once
all_tokens = sum(clean_query, [])
#tokens_once = set(word for word in set(clean_query) if clean_query.count(word) == 1)
tokens_once = set(word for word in set(all_tokens) if all_tokens.count(word) < 300)
texts = [[word for word in text if word not in tokens_once] for text in clean_query]

dictionary = corpora.Dictionary(texts)
corpus = [dictionary.doc2bow(text) for text in texts]
ldamodel = gensim.models.ldamodel.LdaModel(corpus, num_topics=100, id2word = dictionary, passes=20)

#[(37, u'0.285*micromax + 0.212*canvas + 0.159*silver + 0.157*spark + 0.101*adapter + 0.055*fridge + 0.016*nitro + 0.012*bolt + 0.000*paint + 0.000*school'), (41, u'0.499*wifi + 0.207*router + 0.106*dongle + 0.097*modem + 0.071*cd + 0.017*antivirus + 0.000*paint + 0.000*tube + 0.000*guitar + 0.000*nail'), (71, u'0.504*card + 0.183*memory + 0.160*ear + 0.082*data + 0.068*sound + 0.000*spray + 0.000*tube + 0.000*school + 0.000*supply + 0.000*colour'), (10, u'0.535*speaker + 0.217*offer + 0.090*tunic + 0.074*curtain + 0.056*foot + 0.023*9 + 0.004*logitech + 0.000*spray + 0.000*nail + 0.000*paint'), (3, u'0.315*wwe + 0.241*bra + 0.133*blue + 0.119*pro + 0.085*tower + 0.069*inner + 0.036*cup + 0.000*nail + 0.000*colour + 0.000*guitar'), (89, u'0.704*4 + 0.288*perfume + 0.000*spray + 0.000*tube + 0.000*paint + 0.000*school + 0.000*guitar + 0.000*supply + 0.000*running + 0.000*colour'), (99, u'0.312*0 + 0.255*printer + 0.221*laser + 0.194*otg + 0.009*epson + 0.000*paint + 0.000*colour + 0.000*spray + 0.000*tube + 0.000*sneaker'), (27, u'0.318*plus + 0.305*x + 0.242*light + 0.059*duo + 0.030*motorola + 0.012*milk + 0.011*processor + 0.010*titanium + 0.010*chocolate + 0.000*school'), (48, u'0.289*32gb + 0.277*16gb + 0.160*trouser + 0.082*lunch + 0.076*iphone + 0.070*multi + 0.042*milton + 0.000*paint + 0.000*tube + 0.000*colour'), (39, u'0.687*shoe + 0.187*casual + 0.086*sparx + 0.039*earring + 0.000*nail + 0.000*guitar + 0.000*paint + 0.000*spray + 0.000*supply + 0.000*colour'), (81, u'0.566*xiaomi + 0.191*yamaha + 0.178*mi + 0.028*key + 0.022*lock + 0.014*4gb + 0.000*footwear + 0.000*guitar + 0.000*soap + 0.000*colour'), (58, u'0.460*chain + 0.174*cabinet + 0.143*free + 0.107*10000 + 0.104*deo + 0.000*school + 0.000*sneaker + 0.000*spray + 0.000*nail + 0.000*tube'), (2, u'0.278*bluetooth + 0.261*jean + 0.159*hair + 0.092*hand + 0.077*cube + 0.035*style + 0.029*nova + 0.022*eye + 0.019*straightener + 0.016*dryer'), (65, u'0.644*2 + 0.207*wallet + 0.067*computer + 0.053*cutter + 0.027*indian + 0.000*colour + 0.000*nail + 0.000*guitar + 0.000*supply + 0.000*spray'), (86, u'0.328*school + 0.224*jacket + 0.109*boot + 0.107*selfie + 0.103*stick + 0.059*product + 0.025*microwave + 0.022*lakme + 0.018*deodorant + 0.000*nail'), (8, u'0.286*car + 0.265*case + 0.187*v + 0.089*wash + 0.071*care + 0.067*shampoo + 0.034*polish + 0.000*school + 0.000*spray + 0.000*paint'), (77, u'0.953*men + 0.040*powder + 0.006*gent + 0.000*paint + 0.000*school + 0.000*spray + 0.000*colour + 0.000*tube + 0.000*nail + 0.000*man'), (85, u"0.469*watch + 0.182*black + 0.082*wrist + 0.065*yonex + 0.047*women's + 0.025*badminton + 0.025*fashion + 0.021*fastrack + 0.021*underwear + 0.018*men's"), (83, u'0.558*flip + 0.292*slipper + 0.101*flop + 0.046*speed + 0.000*paint + 0.000*spray + 0.000*tube + 0.000*sneaker + 0.000*nail + 0.000*flat'), (0, u'0.626*keyboard + 0.128*cycle + 0.123*gear + 0.077*11 + 0.036*ncert + 0.000*tube + 0.000*paint + 0.000*school + 0.000*colour + 0.000*nail'), (46, u'0.429*nokia + 0.208*furniture + 0.191*fit + 0.163*dvd + 0.000*nail + 0.000*supply + 0.000*colour + 0.000*guitar + 0.000*spray + 0.000*soap'), (17, u'0.488*wireless + 0.215*1 + 0.182*game + 0.042*equipment + 0.035*intex + 0.024*le + 0.006*letv + 0.006*cloud + 0.000*school + 0.000*nail'), (79, u'0.557*prime + 0.185*tyre + 0.120*lens + 0.085*filter + 0.028*flash + 0.021*dslr + 0.000*spray + 0.000*school + 0.000*sneaker + 0.000*nail'), (92, u'0.445*& + 0.314*bag + 0.056*ring + 0.035*travel + 0.031*cleaner + 0.023*sling + 0.022*protein + 0.021*scooter + 0.020*nutrition + 0.014*college'), (57, u'0.470*home + 0.255*theatre + 0.086*5.1 + 0.080*1tb + 0.054*ipod + 0.037*apple + 0.008*ipad + 0.006*f&d + 0.000*school + 0.000*paint'), (31, u'0.323*battery + 0.235*pearl + 0.190*pen + 0.158*drive + 0.062*low + 0.021*diamond + 0.008*inverter + 0.000*school + 0.000*spray + 0.000*tube'), (56, u'0.317*woodland + 0.164*belt + 0.155*system + 0.144*8gb + 0.131*leather + 0.046*audio + 0.036*music + 0.004*levi + 0.000*running + 0.000*spray'), (82, u'0.235*slim + 0.182*piece + 0.170*blouse + 0.165*skin + 0.094*gaming + 0.084*lotion + 0.065*bath + 0.000*spray + 0.000*tube + 0.000*nail'), (42, u'0.385*legging + 0.303*g + 0.206*hp + 0.095*htc + 0.000*paint + 0.000*spray + 0.000*nail + 0.000*colour + 0.000*sneaker + 0.000*supply'), (34, u'0.319*table + 0.303*camera + 0.108*chair + 0.078*mat + 0.056*cloth + 0.039*original + 0.038*office + 0.019*pampers + 0.015*diaper + 0.011*cartridge'), (78, u'0.297*pendrive + 0.273*stabilizer + 0.221*1.5 + 0.194*z + 0.006*godrej + 0.003*blackberry + 0.000*paint + 0.000*guitar + 0.000*tube + 0.000*colour'), (52, u'0.345*high + 0.280*smartphones + 0.251*automatic + 0.110*ankle + 0.000*supply + 0.000*nail + 0.000*tube + 0.000*guitar + 0.000*colour + 0.000*soap'), (20, u'0.323*zenfone + 0.232*max + 0.166*vlcc + 0.136*washing + 0.090*face + 0.021*scrub + 0.017*asus + 0.012*massager + 0.001*amway + 0.000*tube'), (59, u'0.372*short + 0.218*one + 0.150*class + 0.103*touch + 0.097*clothing + 0.057*lehengas + 0.000*nail + 0.000*colour + 0.000*seat + 0.000*diaper'), (90, u'0.481*pant + 0.294*track + 0.216*pump + 0.004*electronic + 0.000*spray + 0.000*tube + 0.000*school + 0.000*colour + 0.000*paint + 0.000*supply'), (23, u'0.465*tshirt + 0.252*u + 0.184*r + 0.070*house + 0.023*dell + 0.000*nail + 0.000*colour + 0.000*tube + 0.000*guitar + 0.000*supply'), (53, u'0.970*[c][[c]] + 0.011*half + 0.008*series + 0.007*turbo + 0.003*love + 0.000*tube + 0.000*paint + 0.000*nail + 0.000*school + 0.000*flat'), (75, u'0.266*total + 0.263*rechargeable + 0.258*security + 0.191*watt + 0.000*supply + 0.000*spray + 0.000*school + 0.000*nail + 0.000*colour + 0.000*tube'), (87, u'0.266*lady + 0.246*footwear + 0.179*blade + 0.134*small + 0.070*decor + 0.048*brown + 0.034*best + 0.016*amplifier + 0.004*barbie + 0.000*nail'), (62, u'0.577*cotton + 0.294*kurti + 0.097*neck + 0.029*pillow + 0.000*nail + 0.000*tube + 0.000*school + 0.000*paint + 0.000*colour + 0.000*running'), (19, u'0.557*sandal + 0.144*flat + 0.078*floater + 0.061*towel + 0.054*gas + 0.052*burner + 0.049*stove + 0.000*spray + 0.000*school + 0.000*nail'), (9, u'0.577*saree + 0.137*western + 0.078*silk + 0.070*oil + 0.044*beige + 0.026*panel + 0.025*green + 0.025*50 + 0.016*plain + 0.000*paint'), (25, u'0.178*gold + 0.156*red + 0.131*necklace + 0.118*color + 0.085*jewellery + 0.080*pc + 0.064*stone + 0.058*frame + 0.042*art + 0.031*photo'), (33, u'0.645*note + 0.084*hard + 0.064*lenovo + 0.054*disk + 0.053*external + 0.032*tb + 0.028*vibe + 0.018*lite + 0.016*internal + 0.005*coolpad'), (29, u'0.512*tablet + 0.193*3g + 0.170*swipe + 0.074*calling + 0.047*deal + 0.000*tube + 0.000*guitar + 0.000*spray + 0.000*supply + 0.000*nail'), (44, u'0.269*galaxy + 0.161*kurtis + 0.148*headphone + 0.143*wooden + 0.115*earphone + 0.059*sleeve + 0.047*door + 0.042*sofa + 0.017*4th + 0.000*spray'), (36, u'0.552*dress + 0.174*material + 0.096*backpack + 0.092*price + 0.066*pad + 0.020*makeup + 0.000*spray + 0.000*nail + 0.000*flat + 0.000*tube'), (24, u'0.377*machine + 0.275*long + 0.166*guard + 0.065*bangle + 0.062*bracelet + 0.053*sewing + 0.000*spray + 0.000*paint + 0.000*tube + 0.000*nail'), (95, u'0.413*headset + 0.209*moto + 0.193*ram + 0.096*2gb + 0.070*branded + 0.014*gionee + 0.000*guitar + 0.000*soap + 0.000*honda + 0.000*supply'), (1, u'0.405*puma + 0.131*pouch + 0.118*gt + 0.068*ro + 0.061*aqua + 0.060*20 + 0.053*juice + 0.036*pot + 0.033*flower + 0.031*induction')]    

ldamodel = gensim.models.ldamodel.LdaModel(corpus, num_topics=50, id2word = dictionary, passes=20)
