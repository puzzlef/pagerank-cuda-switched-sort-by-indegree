#include <cstdio>
#include <iostream>
#include <algorithm>
#include "src/main.hxx"

using namespace std;




#define REPEAT 5

template <class G, class H>
void runPagerank(const G& x, const H& xt, bool show) {
  typedef PagerankSort Sort;
  vector<float> *init = nullptr;

  // Find pagerank using nvGraph.
  auto a1 = pagerankNvgraph(xt, init, {REPEAT});
  auto e1 = l1Norm(a1.ranks, a1.ranks);
  printf("[%09.3f ms; %03d iters.] [%.4e err.] pagerankNvgraph\n", a1.time, a1.iterations, e1);

  for (int vertex=0; vertex<3; vertex++) {
    for (int edge=0; edge<3; edge++) {
      Sort sortVertex = static_cast<Sort>(vertex);
      Sort sortEdge   = static_cast<Sort>(edge);
      // Find pagerank using CUDA block-per-vertex.
      auto a2 = pagerankCuda(xt, init, {REPEAT, sortVertex, sortEdge});
      auto e2 = l1Norm(a2.ranks, a1.ranks);
      printf("[%09.3f ms; %03d iters.] [%.4e err.] pagerankCuda [sortv=%s; sorte=%s]\n", a2.time, a2.iterations, e2, stringify(sortVertex).c_str(), stringify(sortEdge).c_str());
    }
  }
}


int main(int argc, char **argv) {
  char *file = argv[1];
  bool  show = argc > 2;
  printf("Loading graph %s ...\n", file);
  auto x  = readMtx(file); println(x);
  auto xt = transposeWithDegree(x); print(xt); printf(" (transposeWithDegree)\n");
  runPagerank(x, xt, show);
  printf("\n");
  return 0;
}