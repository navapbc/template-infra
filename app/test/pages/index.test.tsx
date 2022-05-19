// test/pages/index.test.js

import React from "react";
import { render, screen } from "@testing-library/react";
import Home from "../../pages/index";

describe("Home", () => {
  it("should render the heading", () => {
    render(<Home />);

    const heading = screen.getByText(
      /Next.js Template!/i
    );

    expect(heading).toBeInTheDocument();
    expect(heading).toMatchSnapshot();
  });
});