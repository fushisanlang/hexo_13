---
title: lda学习demo-testModel.py
tags:
  - python
  - lda
  - demo
categories:
  - note
  - demo
abbrlink: 16f14016
date: 2023-01-04 00:00:00
---
# lda学习demo-testModel.py
```python
from gensim.models.ldamodel import LdaModel
from gensim import corpora
import fileinput
import re
import jieba

#加载模型
modelPath="model_lda1/model_lda1"
model=LdaModel.load(modelPath)

#加载需要预测的文本
fileName="data/test.txt"
a=""
for line in fileinput.input(fileName,openhook=fileinput.hook_encoded('utf-8', '')):
    a=a+line


def stopwordsPattern():
    stopwordsPatternList=[]
    for i in  open('data/stopWord.txt',encoding='UTF-8').readlines():
        stopwordsPatternList.append(re.sub(r"\n","",i))
    return stopwordsPatternList
def paperCut(intxt,pattern=stopwordsPattern()):
    aList=jieba.lcut(intxt)
    for i in aList:
        if i in pattern:
            aList.remove(i)
    return aList


#对文本分词
aList=[]

aList.append(paperCut(a))

#文本向量化
wordDict=corpora.Dictionary(aList)
corpus=wordDict.doc2bow(aList[0])

#文本对比
doc_lda = model[corpus]
scoreList=[]
for a in doc_lda:
    scoreList.append(a[1])
maxIndex=scoreList.index(max(scoreList))
print(doc_lda[maxIndex])
print(model.print_topics()[maxIndex])

```