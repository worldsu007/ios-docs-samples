//
// Copyright 2019 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import googleapis

extension Entity_Type {
  func getEntityType() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .unknown:
      return "NA"
    case .person:
      return "PERSON"
    case .location:
      return "LOCATION"
    case .organization:
      return "ORGANIZATION"
    case .event:
      return "EVENT"
    case .workOfArt:
      return "WORK OF ART"
    case .consumerGood:
      return "CONSUMER GOOD"
    case .other:
      return "OTHER"
    case .phoneNumber:
      return "PHONE NUMBER"
    case .address:
      return "ADDREDD"
    case .date:
      return "DATE"
    case .number:
      return "NUMBER"
    case .price:
      return "PRICE"
    @unknown default:
      return "NA"
    }
  }
}

extension DependencyEdge_Label {
  func getDependencyEdgeLabel() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .unknown:
      return ""
    case .abbrev:
      return "abbrev"
    case .acomp:
      return "acomp"
    case .advcl:
      return "advcl"
    case .advmod:
      return "advmod"
    case .amod:
      return "amod"
    case .appos:
      return "appos"
    case .attr:
      return "attr"
    case .aux:
      return "aux"
    case .auxpass:
      return "auxpass"
    case .cc:
      return "cc"
    case .ccomp:
      return "ccomp"
    case .conj:
      return "conj"
    case .csubj:
      return "csubj"
    case .csubjpass:
      return "csubjpass"
    case .dep:
      return "dep"
    case .det:
      return "det"
    case .discourse:
      return "discourse"
    case .dobj:
      return "dobj"
    case .expl:
      return "expl"
    case .goeswith:
      return "goeswith"
    case .iobj:
      return "iobj"
    case .mark:
      return "mark"
    case .mwe:
      return "mwe"
    case .mwv:
      return "mwv"
    case .neg:
      return "neg"
    case .nn:
      return "nn"
    case .npadvmod:
      return "npadvmod"
    case .nsubj:
      return "nsubj"
    case .nsubjpass:
      return "nsubjpass"
    case .num:
      return "num"
    case .number:
      return "number"
    case .P:
      return "Punc"
    case .parataxis:
      return "parataxis"
    case .partmod:
      return "partmod"
    case .pcomp:
      return "pcomp"
    case .pobj:
      return "pobj"
    case .poss:
      return "poss"
    case .postneg:
      return "postneg"
    case .precomp:
      return "precomp"
    case .preconj:
      return "preconj"
    case .predet:
      return "predet"
    case .pref:
      return "pref"
    case .prep:
      return "prep"
    case .pronl:
      return "pronl"
    case .prt:
      return "prt"
    case .ps:
      return "prt"
    case .quantmod:
      return "quantmod"
    case .rcmod:
      return "rcmod"
    case .rcmodrel:
      return "rcmodrel"
    case .rdrop:
      return "rdrop"
    case .ref:
      return "ref"
    case .remnant:
      return "remnant"
    case .reparandum:
      return "reparandum"
    case .root:
      return "root"
    case .snum:
      return "snum"
    case .suff:
      return "suff"
    case .tmod:
      return "tmod"
    case .topic:
      return "topic"
    case .vmod:
      return "vmod"
    case .vocative:
      return "vocative"
    case .xcomp:
      return "xcomp"
    case .suffix:
      return "suffix"
    case .title:
      return "title"
    case .advphmod:
      return "advphmod"
    case .auxcaus:
      return "auxcaus"
    case .auxvv:
      return "auxvv"
    case .dtmod:
      return "dtmod"
    case .foreign:
      return "foreign"
    case .kw:
      return "Keyword"
    case .list:
      return "list"
    case .nomc:
      return "nomc"
    case .nomcsubj:
      return "nomcsubj"
    case .nomcsubjpass:
      return "nomcsubjpass"
    case .numc:
      return "numc"
    case .cop:
      return "cop"
    case .dislocated:
      return "dislocated"
    case .asp:
      return "asp"
    case .gmod:
      return "gmod"
    case .gobj:
      return "gobj"
    case .infmod:
      return "infmod"
    case .mes:
      return "mes"
    case .ncomp:
      return "ncomp"
    @unknown default:
      return ""
    }
  }
}

extension PartOfSpeech_Tag {
  func getPartOfSpeechTag() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .unknown:
      return ""
    case .adj:
      return "adj"
    case .adp:
      return "adp"
    case .adv:
      return "adv"
    case .conj:
      return "conj"
    case .det:
      return "det"
    case .noun:
      return "noun"
    case .num:
      return "num"
    case .pron:
      return "pron"
    case .prt:
      return "prt"
    case .punct:
      return "punct"
    case .verb:
      return "verb"
    case .X:
      return "X"
    case .affix:
      return "affix"
    @unknown default:
      return ""
    }
  }
}

extension PartOfSpeech_Number {
  func getNumberString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .numberUnknown:
      return ""
    case .singular:
      return "singular"
    case .plural:
      return "plural"
    case .dual:
      return "dual"
    @unknown default:
      return ""
    }
  }
  func hasNumber() -> Bool {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .numberUnknown:
      return false
    case .singular, .plural, .dual:
      return true
    @unknown default:
      return false
    }
  }
}

extension PartOfSpeech_Proper {
  func hasProper() -> Bool {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .properUnknown:
      return false
    case .proper, .notProper:
      return true
    @unknown default:
      return false
    }
  }
  func getProperString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .properUnknown:
      return ""
    case .proper:
      return "proper"
    case .notProper:
      return "not Proper"
    @unknown default:
      return ""
    }
  }
}

extension PartOfSpeech_Tense {
  func hasTense() -> Bool {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .tenseUnknown:
      return false
    case .conditionalTense, .future, .past, .present, .imperfect, .pluperfect:
      return true
    @unknown default:
      return false
    }
  }
  func getTenseString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .tenseUnknown:
      return ""
    case .conditionalTense:
      return "Conditional Tense"
    case .future:
      return "future"
    case .past:
      return "past"
    case .present:
      return "present"
    case .imperfect:
      return "imperfect"
    case .pluperfect:
      return "pluperfect"
    @unknown default:
      return ""
    }
  }
}

extension PartOfSpeech_Mood {
  func hasMood() -> Bool {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .moodUnknown:
      return false
    case .conditionalMood, .imperative, .indicative, .interrogative, .subjunctive, .jussive:
      return true
    @unknown default:
      return false
    }
  }
  func getMoodString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .moodUnknown:
      return ""
    case .conditionalMood:
      return "conditional Mood"
    case .imperative:
      return "imperative"
    case .indicative:
      return "indicative"
    case .interrogative:
      return "interrogative"
    case .jussive:
      return "jussive"
    case .subjunctive:
      return "subjunctive"
    @unknown default:
      return ""
    }
  }
}

extension PartOfSpeech_Case {
  func hasCase() -> Bool {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .caseUnknown:
      return false
    case .accusative, .adverbial, .complementive, .dative, .genitive, .instrumental, .locative, .nominative, .oblique, .partitive, .prepositional, .reflexiveCase, .relativeCase, .vocative:
      return true
    @unknown default:
      return false
    }
  }

  func getCaseString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .caseUnknown:
      return ""
    case .accusative:
      return "accusative"
    case .adverbial:
      return "adverbial"
    case .complementive:
      return "complementive"
    case .dative:
      return "dative"
    case .genitive:
      return "genitive"
    case .instrumental:
      return "instrumental"
    case .locative:
      return "locative"
    case .nominative:
      return "nominative"
    case .oblique:
      return "oblique"
    case .partitive:
      return "partitive"
    case .prepositional:
      return "prepositional"
    case .reflexiveCase:
      return "reflexiveCase"
    case .relativeCase:
      return "relativeCase"
    case .vocative:
      return "vocative"
    @unknown default:
      return ""
    }
  }
}

extension PartOfSpeech_Gender {
  func hasGender() -> Bool {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .genderUnknown:
      return false
    case .feminine, .masculine, .neuter:
      return true
    @unknown default:
      return false
    }
  }
  func getGenderString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .genderUnknown:
      return ""
    case .feminine:
      return "feminine"
    case .masculine:
      return "masculine"
    case .neuter:
      return "neuter"
    @unknown default:
      return ""
    }
  }
}

extension PartOfSpeech_Person {
  func hasPerson() -> Bool {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .personUnknown:
      return false
    case .first, .second, .third, .reflexivePerson:
      return true
    @unknown default:
      return false
    }
  }
  func getPersonString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue, .personUnknown:
      return ""
    case .first:
      return "first"
    case .second:
      return "second"
    case .third:
      return "third"
    case .reflexivePerson:
      return "reflexive Person"
    @unknown default:
      return ""
    }
  }
}

class EntityTableViewCell: UITableViewCell {
  @IBOutlet weak var entityNameLabel: UILabel!
  @IBOutlet weak var entityTypeLabel: UILabel!
  @IBOutlet weak var entityURLLeftLabel: UILabel!
  @IBOutlet weak var entityURLRightLabel: UILabel!
  @IBOutlet weak var entitySalienceLabel: UILabel!
  @IBOutlet weak var entiySalienceLeftLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func configureWith(entity: Entity) {
    entityNameLabel.text = entity.name
    entityTypeLabel.text = entity.type.getEntityType()
    if let metaData = entity.metadata as? Dictionary<String, Any>, let wikiURL = metaData["wikipedia_url"] as? String {
      entityURLRightLabel.text = wikiURL
    }
    entityURLLeftLabel.text = "URL: "
    entitySalienceLabel.text = "\(entity.salience)"
    entiySalienceLeftLabel.text = "Salience: "
  }

  func configureEntitySentiment(entity: Entity) {
    entityNameLabel.text = entity.name
    entityTypeLabel.text = entity.type.getEntityType()
    entityURLLeftLabel.text = "Sentiment"
    entityURLRightLabel.text = "Score: \(entity.sentiment.score) Magnitude: \(entity.sentiment.magnitude)"
    entitySalienceLabel.text = ""
    entiySalienceLeftLabel.text = ""
  }

}

class SentimentTableViewCell: UITableViewCell {
  @IBOutlet weak var sentenceLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var magnitudeLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func configureWith(sentence: Sentence) {
    sentenceLabel.text = sentence.hasText ? (sentence.hasSentiment ? ApplicationConstants.sentence +  sentence.text.content : sentence.text.content) : ""
    scoreLabel.text = sentence.hasSentiment ? "Score: \(sentence.sentiment.score)" : ""
    magnitudeLabel.text = sentence.hasSentiment ? "Magnitude: \(sentence.sentiment.magnitude)" : ""
  }
  
  func configureWith(category: ClassificationCategory) {
    sentenceLabel.text = "Name: " + (category.name ?? "")
    sentenceLabel.font = .boldSystemFont(ofSize: 14)
    scoreLabel.text = "Confidence: " + "\(category.confidence)"
    magnitudeLabel.text = ""
  }
}

class SyntaxTableViewCell: UITableViewCell {
  @IBOutlet var textLabels: [UILabel]!
  @IBOutlet var partOFSpeechLabels: [UILabel]!
  @IBOutlet var dependencyEdgeLabels: [UILabel]!
  @IBOutlet var lemmaLabels: [UILabel]!
  @IBOutlet var morphologyLabels: [UILabel]!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    for i in 0 ..< textLabels.count {
      textLabels[i].text = ""
      dependencyEdgeLabels[i].text = ""
      partOFSpeechLabels[i].text = ""
      lemmaLabels[i].text = ""
      morphologyLabels[i].text = ""
    }
  }

  func configureWith(sentences: [Token], selectedOptions: [SyntaxOptions]) {
    for i in 0 ..< textLabels.count {
      textLabels[i].text = ""
      dependencyEdgeLabels[i].text = ""
      partOFSpeechLabels[i].text = ""
      lemmaLabels[i].text = ""
      morphologyLabels[i].text = ""
    }
    for (index, sentence) in sentences.enumerated() {
      textLabels[index].text = sentence.hasText ?  sentence.text.content : ""
      for selectedOption in selectedOptions {
        switch selectedOption {
        case .dependency:
          dependencyEdgeLabels[index].text = sentence.hasDependencyEdge ? sentence.dependencyEdge.label.getDependencyEdgeLabel().uppercased() : ""
        case .partOfSpeech:
          partOFSpeechLabels[index].text = sentence.hasPartOfSpeech ? sentence.partOfSpeech.tag.getPartOfSpeechTag().uppercased() : ""
        case .lemma:
          lemmaLabels[index].text = sentence.lemma == sentence.text.content ? "" : sentence.lemma
        case .morphology:
          morphologyLabels[index].text = sentence.hasPartOfSpeech ? getMorphologyText(partOfSpeech: sentence.partOfSpeech) : ""
        }
      }
    }
  }

  func getMorphologyText(partOfSpeech: PartOfSpeech) -> String {
    var morphologyText = ""
    if partOfSpeech.number.hasNumber() {
      morphologyText += "Number = \(partOfSpeech.number.getNumberString().uppercased())"
    }
    if partOfSpeech.proper.hasProper() {
      morphologyText += "\nProper = \(partOfSpeech.proper.getProperString().uppercased())"
    }
    if partOfSpeech.tense.hasTense() {
      morphologyText += "\nTense = \(partOfSpeech.tense.getTenseString().uppercased())"
    }
    if partOfSpeech.mood.hasMood() {
      morphologyText += "\nMood = \(partOfSpeech.mood.getMoodString().uppercased())"
    }
    if partOfSpeech.case_p.hasCase() {
      morphologyText += "\nCase = \(partOfSpeech.case_p.getCaseString().uppercased())"
    }
    if partOfSpeech.gender.hasGender() {
      morphologyText += "\nGender = \(partOfSpeech.gender.getGenderString().uppercased())"
    }
    if partOfSpeech.person.hasPerson() {
      morphologyText += "\nPerson = \(partOfSpeech.person.getPersonString().uppercased())"
    }
    return morphologyText
  }
}
