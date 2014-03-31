// Scénario type 2 parents cadres et 2 enfants
// Json object
var scenario = {
    test_case: {
        familles: [{
            parents: ["ind0", "ind1"],
            enfants: ["ind2", "ind3"]
        }],
        foyers_fiscaux: [{
            declarants: ["ind0", "ind1"],
            personnes_a_charge: ["ind2", "ind3"]
        }],
        individus: [
            { activite: "Actif occupé", birth: "1970-01-01", cadre: true, id: "ind0", sali: 35000, statmarit: "Marié" },
            { activite: "Actif occupé", birth: "1970-01-02", cadre: true, id: "ind1", sali: 35000, statmarit: "Marié" },
            { activite: "Étudiant, élève", birth: "2000-01-03", id: "ind2" },
            { activite: "Étudiant, élève", birth: "2000-01-04", id: "ind3" }], 
        menages: [{
            personne_de_reference: "ind0",
            conjoint: "ind1",
            enfants: ["ind2", "ind3"] 
        }]
    },
    year: 2013    
}

console.log(JSON.stringify(scenario));

// Connexion à l'api
$.ajax("http://api.openfisca.fr/api/1/simulate", {
    contentType: "application/json",
    data: JSON.stringify({
        scenarios: [scenario]
    }),
    dataType: "json",
    type: "POST",
    xhrFields: {
        withCredentials: true
    }
})
.done(function (data, textStatus, jqXHR) {
    // Data incoming...
    var dataString = JSON.stringify(data);
    $('code#json_returned').text(dataString);
})
.fail(function (jqXHR, textStatus, errorThrown) {
    // err
    console.log("fail");
    console.log(jqXHR);
    console.log(textStatus);
    console.log(errorThrown);
});