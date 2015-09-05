# Nim wrapper around the Big Huge Thesaurus API (http://words.bighugelabs.com/api.php).

# Written by Adam Chesak.
# Released under the MIT open source license.


import httpclient
import strutils

type
    BHWordList* = ref BHWordListInternal
    
    BHWordListInternal* = object
        synonyms : seq[string]
        antonyms : seq[string]
        related : seq[string]
        similar : seq[string]
        userSuggestions : seq[string]
    
    BHThesaurus* = ref BHThesaurusInternal
    
    BHThesaurusInternal* = object
        noun : BHWordList
        verb : BHWordList


proc getThesarusEntry*(apikey : string, word : string): BHThesaurus = 
    ## Gets the thesarus entry for the given ``word``.
    
    var response : string = getContent("http://words.bighugelabs.com/api/2/" & apikey & "/" & word & "/")
    var noun : BHWordList = BHWordList(synonyms: @[], antonyms: @[], related: @[], similar: @[], userSuggestions: @[])
    var verb : BHWordList = BHWordList(synonyms: @[], antonyms: @[], related: @[], similar: @[], userSuggestions: @[])
    var entry : BHThesaurus = BHThesaurus(noun: noun, verb: verb)
    
    var lines : seq[string] = response.splitLines()
    for i in lines:
        
        var field : string = i.strip(leading = true, trailing = true)
        if field == "":
            continue
        
        var fieldItems : seq[string] = field.split("|")
        if fieldItems[0] == "noun":
            if fieldItems[1] == "syn":
                noun.synonyms.add(fieldItems[2])
            elif fieldItems[1] == "ant":
                noun.antonyms.add(fieldItems[2])
            elif fieldItems[1] == "rel":
                noun.related.add(fieldItems[2])
            elif fieldItems[1] == "sim":
                noun.similar.add(fieldItems[2])
            elif fieldItems[1] == "usr":
                noun.userSuggestions.add(fieldItems[2])
        elif fieldItems[1] == "verb":
            if fieldItems[1] == "syn":
                verb.synonyms.add(fieldItems[2])
            elif fieldItems[1] == "ant":
                verb.antonyms.add(fieldItems[2])
            elif fieldItems[1] == "rel":
                verb.related.add(fieldItems[2])
            elif fieldItems[1] == "sim":
                verb.similar.add(fieldItems[2])
            elif fieldItems[1] == "usr":
                verb.userSuggestions.add(fieldItems[2])
    
    return entry
