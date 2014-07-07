// Fractal pentagon implementation from Matt Pearson's excellent "Generative Art: a Practical Guide Using Processing"

FractalRoot pentagon;
int _numSides = 9;
int _maxLevels = 4;
float _strutFactor = 0.2;
float _noiseRoot;
float _totAngle = 720.0f;

void setup() {
	size(1000, 1000);
	smooth();
	_noiseRoot = random(10);
}

void draw() {
	background(255);

	_noiseRoot += 0.01;
	_strutFactor = (noise(_noiseRoot) * 3) - 1.5;

	pentagon = new FractalRoot(radians(-frameCount / 2));
	pentagon.drawShape();
}

class FractalRoot {
	PVector[] pointArr = new PVector[_numSides];
	Branch rootBranch;

	FractalRoot(float startAngle) {
		float centX = width / 2;
		float centY = height / 2;
		float ang = 0;
		float angleStep = _totAngle / _numSides;
		for (int count = 0; count < _numSides; count++) {
			float x = centX + 400 * cos(radians(startAngle + ang));
			float y = centY + 400 * sin(radians(startAngle + ang));
			pointArr[count] = new PVector(x, y);
			ang += angleStep;
		}
		rootBranch = new Branch(0, 0, pointArr);
	};

	void drawShape() {
		rootBranch.draw();
	}
}

class Branch {
	int level, num;
	PVector[] outerPoints = {};
	PVector[] midPoints = {};
	PVector[] projPoints = {};
	Branch[] branches = {};

	Branch(int lev, int n, PVector[] points) {
		level = lev;
		num = n;
		outerPoints = points;
		midPoints = calcMidPoints();
		projPoints = calcStrutPoints();

		if (level + 1 < _maxLevels) {
			Branch centerBranch = new Branch(level + 1, 0, projPoints);
			appendBranch(centerBranch);

			for (int i = 0, l = outerPoints.length; i < l; ++i) {
				int nexti = i - 1;
				if (nexti < 0) { nexti += l; }
				PVector[] childPoints = {outerPoints[i], midPoints[i], projPoints[i], projPoints[nexti], midPoints[nexti]};
				Branch perimBranch = new Branch(level + 1, i + 1, childPoints);
				appendBranch(perimBranch);
			}
		}
	}

	void appendBranch(Branch childBranch) {
		branches = (Branch[]) append(branches, childBranch);
	}

	void draw() {
		strokeWeight(5 / (level + 1));
		// draw outer shape
		for (int i = 0; i < outerPoints.length; i++) {
			int nexti = i + 1;
			if (nexti == outerPoints.length) { nexti = 0; }
			line(outerPoints[i].x, outerPoints[i].y, outerPoints[nexti].x, outerPoints[nexti].y);
		}

		for (int i = 0, l = branches.length; i < l; ++i) {
			branches[i].draw();
		}
	}

	PVector[] calcMidPoints() {
		PVector[] mpArr = new PVector[outerPoints.length];
		for (int i = 0; i < outerPoints.length; i++) {
			int nexti = i + 1;
			if (nexti == outerPoints.length) { nexti = 0; }
			PVector mp = midPoint(outerPoints[i], outerPoints[nexti]);
			mpArr[i] = mp;
		}
		return mpArr;
	}

	PVector midPoint(PVector a, PVector b) {
		return new PVector((a.x + b.x) / 2, (a.y + b.y) / 2);
	}

	PVector[] calcStrutPoints() {
		PVector[] strutArr = new PVector[midPoints.length];
		for (int i = 0, l = midPoints.length; i < l; ++i) {
			int oppInd = i + 3;
			if (oppInd >= l) { oppInd -= l; }
			PVector strutPt = calcProjPoint(midPoints[i], outerPoints[oppInd]);
			strutArr[i] = strutPt;
		}
		return strutArr;
	}

	PVector calcProjPoint(PVector mp, PVector op) {
		float xd = op.x - mp.x;
		float yd = op.y - mp.y;
		return new PVector(mp.x + (xd * _strutFactor), mp.y + (yd * _strutFactor));
	}
}


