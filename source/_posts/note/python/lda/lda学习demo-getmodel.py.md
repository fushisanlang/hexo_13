---
title: lda学习demo-getmodel.py
tags:
  - python
  - lda
  - demo
categories:
  - note
  - demo
abbrlink: 55b3161a
date: 2023-01-04 00:00:00
---
# lda学习demo-getmodel.py
```python
import pandas as pd
import os
import jieba
from gensim import corpora
from gensim import models
import re
from gensim.models.ldamodel import LdaModel

print(1)
#导入数据
qa=pd.read_excel('data/qa.xlsx',names=['qa'], sheet_name="qa" ,header=None,usecols=[0])

#导入词典

#jieba.del_word("实名认证")
#print(jieba.lcut("实名认证，我是好人"))
keyWords=pd.read_excel('data/qa.xlsx',names=['keywords'],sheet_name="keyWords" ,header=None,usecols=[0])
for k in keyWords.keywords:
    jieba.add_word(k)

import re
def stopwordsPattern():
    stopwordsPatternList=[]
    for i in  open('stopWord.txt',encoding='UTF-8').readlines():
        stopwordsPatternList.append(re.sub(r"\n","",i))
    return stopwordsPatternList
def paperCut(intxt,pattern=stopwordsPattern()):
    aList=jieba.lcut(intxt)
    for i in aList:
        if i in pattern:
            aList.remove(i)
    return aList


#分词
wordList=[]
for paper in qa.qa:
    wordList.append(paperCut(paper,stopwordsPattern()))

#文本向量化
wordDict=corpora.Dictionary(wordList)
corpus=[wordDict.doc2bow(text) for text in wordList]
tfidf_model = models.TfidfModel(corpus)
corpus_tfidf=tfidf_model[corpus]

# lda建模
ldamodel = LdaModel(corpus_tfidf,id2word=wordDict,num_topics=4,passes=5,alpha=5,eta=0.1)

#保存模型
modelName="model_lda1"
dirPath="./{}/".format(modelName)
if not os.path.exists(dirPath):
    os.mkdir(dirPath)
ldamodel.save(dirPath+modelName)
print(2)
```