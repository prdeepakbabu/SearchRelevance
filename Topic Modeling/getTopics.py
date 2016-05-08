sys.path.append('/usr/local/lib/python2.7/dist-packages')
sys.path.append('/home/deepak/anaconda2/bin')
import gensim
from gensim import corpora, models

def review_to_words(raw_review ):
    review_text = BeautifulSoup(raw_review).get_text() 
    tmp = re.sub(","," ",review_text);
    words = tmp.lower().split()                             
    stops = set(stopwords.words("english"))                  
    meaningful_words = [lmtzr.lemmatize(w) for w in words if not w in stops ]        
    res = [None] * len(meaningful_words); counter = 0;
    for i in meaningful_words:
        if re.match("[a-z]+[0-9]+",i) :
            tmp = re.sub("[0-9]+","[d]",i)
            tmp1 = re.sub("[a-z]+","[c]",tmp)
            res[counter] = tmp1
        else:
            res[counter]= i
        counter = counter + 1
    return( " ".join( res ))   
