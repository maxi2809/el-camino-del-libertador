# RankData.gd
class_name RankData

enum RankType { RECLUTA, SOLDADO, CABO, SARGENTO, GRANADERO_HONORARIO }

const RANKS = {
	RankType.RECLUTA: {
		"title": "RECLUTA",
		"stars": 1,
	},
	RankType.SOLDADO: {
		"title": "SOLDADO",
		"stars": 2,
	},
	RankType.CABO: {
		"title": "CABO",
		"stars": 3,
	},
	RankType.SARGENTO: {
		"title": "SARGENTO",
		"stars": 4,
	},
	RankType.GRANADERO_HONORARIO: {
		"title": "GRANADERO HONORARIO DEL EJÉRCITO DE LOS ANDES",
		"stars": 5,
	}
}
